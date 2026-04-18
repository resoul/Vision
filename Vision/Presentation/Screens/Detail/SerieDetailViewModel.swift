import Foundation
import Combine

final class SerieDetailViewModel {
    private let movie: ContentItem
    private let useCase: GetMovieDetailUseCaseProtocol
    private let favoritesUseCase: FavoritesUseCase
    private let progressManager: PlaybackProgressManagerProtocol
    private let playerUseCase: PlayerUseCaseProtocol
    
    @Published var detail: ContentDetail?
    @Published var translations: [Translation] = []
    @Published var activeTranslation: Translation?
    @Published var activeSeasonIndex = 0
    @Published var isLoading = false
    @Published var isFavorite = false
    @Published var progressUpdated = UUID()
    
    private var cancellables = Set<AnyCancellable>()
    var onPlayRequested: ((PlaybackContext) -> Void)?
    
    init(
        movie: ContentItem,
        useCase: GetMovieDetailUseCaseProtocol,
        favoritesUseCase: FavoritesUseCase,
        progressManager: PlaybackProgressManagerProtocol,
        playerUseCase: PlayerUseCaseProtocol
    ) {
        self.movie = movie
        self.useCase = useCase
        self.favoritesUseCase = favoritesUseCase
        self.progressManager = progressManager
        self.playerUseCase = playerUseCase
        
        setupBindings()
    }
    
    private func setupBindings() {
        favoritesUseCase.favoritesPublisher
            .map { [weak self] favorites in
                favorites.contains { $0.id == self?.movie.id }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorite)
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (detailData, translationsData) = try await useCase.fetchDetail(movie: movie, isSeries: true)
            
            await MainActor.run {
                self.detail = detailData
                self.translations = translationsData
                self.activeTranslation = translationsData.first
            }
        } catch {
            print("Error loading series detail: \(error)")
        }
    }

    func toggleFavorite() {
        Task {
            do {
                try await favoritesUseCase.toggle(movie)
            } catch {
                print("Failed to toggle favorite: \(error)")
            }
        }
    }
    
    func selectSeason(index: Int) {
        activeSeasonIndex = index
    }
    
    func refreshProgress() {
        progressUpdated = UUID()
    }
    
    func selectTranslation(index: Int) {
        activeTranslation = translations[safe: index]
        activeSeasonIndex = 0
    }
    
    func play(episode: Episode) {
        guard let translation = activeTranslation,
              let season = translation.seasons[safe: activeSeasonIndex],
              let episodeIndex = season.episodes.firstIndex(where: { $0.id == episode.id }) else { return }
        
        Task {
            guard let stream = await playerUseCase.resolvePreferredStream(from: episode.streams) else { return }

            let context = PlaybackContext.episode(
                id: movie.id,
                season: activeSeasonIndex + 1,
                episode: episodeIndex + 1,
                studio: translation.studio,
                quality: stream.quality,
                url: stream.url,
                title: episode.title
            )
            onPlayRequested?(context)
        }
    }
    
    func getProgress(episodeIndex: Int) -> Double? {
        // Implementation for progress tracking
        return progressManager.getProgress(movieId: movie.id, season: activeSeasonIndex + 1, episode: episodeIndex + 1)?.fraction
    }
    
    func isWatched(episodeIndex: Int) -> Bool {
        return progressManager.isWatched(movieId: movie.id, season: activeSeasonIndex + 1, episode: episodeIndex + 1)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
