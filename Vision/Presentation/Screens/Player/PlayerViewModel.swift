import Foundation
import Combine
import AVFoundation

enum SeekCommand: Equatable {
    case absolute(Double)
    case restart
}

@MainActor
final class PlayerViewModel: ObservableObject {
    private enum PlaybackPersistence {
        static let initialHistoryThresholdSeconds: Double = 5
        static let periodicSaveStepSeconds: Double = 15
    }

    private let queue: [ContentItem]
    private var currentIndex: Int
    
    private let playerUseCase: PlayerUseCaseProtocol
    private let watchHistoryUseCase: WatchHistoryUseCase
    private let progressManager: PlaybackProgressManagerProtocol
    private let settingsUseCase: SettingsUseCaseProtocol
    
    @Published var currentContext: PlaybackContext? {
        didSet { rebuildEpisodeBrowseItems() }
    }
    @Published var translations: [Translation] = [] {
        didSet { rebuildEpisodeBrowseItems() }
    }
    @Published var isLoading = false
    @Published var error: Error?
    @Published var shouldDismiss = false
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var resumePromptTime: Double?
    @Published var seekCommand: SeekCommand?
    @Published var episodeBrowseItems: [EpisodeBrowseItem] = []
    
    private var pendingResumeTime: Double?
    private var pendingAutoResumeTime: Double?
    private var lastAutosavedSecond: Double = -1
    private var isSeekPreviewPersistenceEnabled = true
    private var initialContext: PlaybackContext?
    private var isAutoplayEnabled = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        queue: [ContentItem],
        startIndex: Int,
        initialContext: PlaybackContext?,
        playerUseCase: PlayerUseCaseProtocol,
        watchHistoryUseCase: WatchHistoryUseCase,
        progressManager: PlaybackProgressManagerProtocol,
        settingsUseCase: SettingsUseCaseProtocol
    ) {
        self.queue = queue
        self.currentIndex = startIndex
        self.initialContext = initialContext
        self.playerUseCase = playerUseCase
        self.watchHistoryUseCase = watchHistoryUseCase
        self.progressManager = progressManager
        self.settingsUseCase = settingsUseCase
        
        setupSettingsBinding()
    }

    private func setupSettingsBinding() {
        settingsUseCase.settings
            .map { $0.isAutoplayEnabled }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAutoplayEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func loadCurrent() async {
        guard queue.indices.contains(currentIndex) else { return }
        let item = queue[currentIndex]
 
        pendingResumeTime = nil
        pendingAutoResumeTime = nil
        resumePromptTime = nil
        seekCommand = nil
        lastAutosavedSecond = -1
 
        isLoading = true
        defer { isLoading = false }
 
        do {
            let translations = try await playerUseCase.fetchTranslations(for: item)
            self.translations = translations
 
            let context: PlaybackContext
            if let initialContext, initialContext.movieId == item.id {
                context = initialContext
                self.initialContext = nil
            } else {
                context = try await playerUseCase.resolveInitialContext(for: item)
            }
            
            self.currentContext = context
            try? await watchHistoryUseCase.touch(item)
            checkResumeStatus(for: context)
        } catch {
            self.error = error
        }
    }
    
    private func checkResumeStatus(for context: PlaybackContext) {
        let season: Int?
        let episode: Int?
        switch context {
        case .movie:
            season = nil; episode = nil
        case .episode(_, let s, let e, _, _, _, _):
            season = s; episode = e
        }
        
        if let progress = progressManager.getProgress(movieId: context.movieId, season: season, episode: episode),
           progress.positionSeconds > 10 {
            guard progress.fraction < 0.93 else { return }
            let isStaleProgress = Date().timeIntervalSince(progress.lastUpdated) > 7 * 24 * 3600

            // Fresh progress resumes automatically; stale progress asks user first.
            if isStaleProgress {
                pendingResumeTime = progress.positionSeconds
                resumePromptTime = progress.positionSeconds
            } else {
                pendingAutoResumeTime = progress.positionSeconds
            }
        }
    }
    
    var isAwaitingResumeDecision: Bool {
        pendingResumeTime != nil
    }
    
    func consumeAutoResumeTime() -> Double? {
        let value = pendingAutoResumeTime
        pendingAutoResumeTime = nil
        return value
    }
    
    func resume() {
        if let time = pendingResumeTime {
            seekCommand = .absolute(time)
            pendingResumeTime = nil
            resumePromptTime = nil
        }
    }
    
    func restart() {
        seekCommand = .restart
        pendingResumeTime = nil
        resumePromptTime = nil
    }

    func clearSeekCommand() {
        seekCommand = nil
    }

    var isSeries: Bool {
        guard let context = currentContext else { return false }
        if case .episode = context { return true }
        return false
    }

    var currentSeasonIndex: Int {
        guard case .episode(_, let season, _, _, _, _, _) = currentContext else { return 0 }
        return season
    }

    var currentEpisodeIndex: Int {
        guard case .episode(_, _, let episode, _, _, _, _) = currentContext else { return 0 }
        return episode
    }

    func buildEpisodeBrowseItems() async -> [EpisodeBrowseItem] {
        guard let context = currentContext,
              case .episode(_, let currentSeason, let currentEpisode, let studio, _, _, _) = context,
              let translation = translations.first(where: { $0.studio == studio })
        else { return [] }

        var items: [EpisodeBrowseItem] = []
        for (seasonIndex, season) in translation.seasons.enumerated() {
            let seasonNum = seasonIndex + 1
            for (episodeIndex, episode) in season.episodes.enumerated() {
                let posterURL = await playerUseCase.preferredURL(from: episode.streams) ?? ""
                let episodeNum = episodeIndex + 1
                let progress = progressManager.getProgress(
                    movieId: context.movieId,
                    season: seasonNum,
                    episode: episodeNum
                )
                items.append(EpisodeBrowseItem(
                    season: seasonNum,
                    episode: episodeNum,
                    title: episode.title,
                    posterURL: posterURL,
                    progress: progress?.fraction,
                    isWatched: progressManager.isWatched(movieId: context.movieId, season: seasonNum, episode: episodeNum),
                    isCurrent: seasonNum == currentSeason && episodeNum == currentEpisode
                ))
            }
        }
        return items
    }
    
    func playNext() async {
        if let context = currentContext, case .episode(_, let s, let e, let studio, _, _, _) = context {
            // Check if there's a next episode in the current translation
            if let translation = translations.first(where: { $0.studio == studio }) {
                let seasonIdx = s - 1
                let nextEpIdx = e // next episode is at index e
                
                if let season = translation.seasons[safe: seasonIdx] {
                    if nextEpIdx < season.episodes.count {
                        // Next episode in current season
                        if isAutoplayEnabled {
                            await changeEpisode(season: s, episode: e + 1)
                        } else {
                            shouldDismiss = true
                        }
                        return
                    } else if seasonIdx + 1 < translation.seasons.count {
                        // First episode of next season
                        if isAutoplayEnabled {
                            await changeEpisode(season: s + 1, episode: 1)
                        } else {
                            shouldDismiss = true
                        }
                        return
                    }
                }
            }
            
            // if we are here, it's a series but next episode in same translation not found
            // or series ended.
            shouldDismiss = true
            return
        }
        
        // Fallback to next item in queue for movies or mixed content
        guard currentIndex + 1 < queue.count else {
            shouldDismiss = true
            return
        }
        currentIndex += 1
        await loadCurrent()
    }
    
    func playPrevious() async {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        await loadCurrent()
    }
    
    func changeTranslation(_ translation: Translation) async {
        guard let item = queue[safe: currentIndex],
              let context = currentContext else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newContext = try await playerUseCase.switchTranslation(in: item, translation: translation, currentContext: context)
            self.currentContext = newContext
        } catch {
            self.error = error
        }
    }
    
    func changeEpisode(season: Int, episode: Int) async {
        guard let item = queue[safe: currentIndex],
              let context = currentContext else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let studio: String
            let quality: String
            switch context {
            case .movie(_, let s, let q, _, _):
                studio = s; quality = q
            case .episode(_, _, _, let s, let q, _, _):
                studio = s; quality = q
            }
            
            let newContext = try await playerUseCase.switchEpisode(in: item, season: season, episode: episode, currentStudio: studio, currentQuality: quality)
            self.currentContext = newContext
        } catch {
            self.error = error
        }
    }
    
    func updateProgress(currentTime: Double, duration: Double) {
        self.currentTime = currentTime
        self.duration = duration

        guard isSeekPreviewPersistenceEnabled else { return }
        guard currentTime.isFinite, duration.isFinite, duration > 0 else { return }
        guard currentTime > 0 else { return }
        let shouldDoInitialSave = lastAutosavedSecond < 0 && currentTime >= PlaybackPersistence.initialHistoryThresholdSeconds
        let shouldDoPeriodicSave = abs(currentTime - lastAutosavedSecond) >= PlaybackPersistence.periodicSaveStepSeconds
        guard shouldDoInitialSave || shouldDoPeriodicSave else { return }
        guard let context = currentContext else { return }
        
        lastAutosavedSecond = currentTime
        
        let season: Int?
        let episode: Int?
        switch context {
        case .movie:
            season = nil
            episode = nil
        case .episode(_, let s, let e, _, _, _, _):
            season = s
            episode = e
        }
        
        progressManager.saveProgress(
            movieId: context.movieId,
            season: season,
            episode: episode,
            position: currentTime,
            duration: duration
        )

        // Keep "Watching" section fresh during playback, not only on dismiss/background.
        if let item = queue[safe: currentIndex] {
            let fraction = duration > 0 ? currentTime / duration : 0
            let watched = fraction > 0.93
            let episodeId = episode.map { "\(season ?? 0)x\($0)" }
            Task {
                try? await watchHistoryUseCase.saveProgress(
                    item,
                    episodeId: episodeId,
                    position: currentTime,
                    watched: watched
                )
            }
        }
    }

    func setSeekPreviewPersistenceEnabled(_ isEnabled: Bool) {
        isSeekPreviewPersistenceEnabled = isEnabled
    }
    
    func saveState() async {
        guard let context = currentContext else { return }
        try? await playerUseCase.savePlaybackState(movieId: context.movieId, context: context)
        
        if let item = queue[safe: currentIndex] {
            let season: Int?
            let episode: Int?
            let epId: String?
            
            switch context {
            case .episode(_, let s, let e, _, _, _, _):
                season = s; episode = e; epId = "\(s)x\(e)"
            case .movie:
                season = nil; episode = nil; epId = nil
            }
            
            // CoreData: 93% threshold
            try? await watchHistoryUseCase.saveProgress(item, episodeId: epId, position: currentTime, watched: currentTime > duration * 0.93)
            
            // ProgressManager backup
            progressManager.saveProgress(movieId: context.movieId, season: season, episode: episode, position: currentTime, duration: duration)
        }
    }

    private func rebuildEpisodeBrowseItems() {
        Task { [weak self] in
            guard let self = self else { return }
            let items = await self.buildEpisodeBrowseItems()
            self.episodeBrowseItems = items
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
