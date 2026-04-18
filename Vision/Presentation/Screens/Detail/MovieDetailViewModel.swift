import Foundation
import Combine

final class MovieDetailViewModel {
    private let movie: ContentItem
    private let useCase: GetMovieDetailUseCaseProtocol
    private let favoritesUseCase: FavoritesUseCase
    private let progressManager: PlaybackProgressManagerProtocol
    
    @Published var detail: ContentDetail?
    @Published var translations: [Translation] = []
    @Published var isLoading = false
    @Published var isFavorite = false
    @Published var isWatched = false
    
    private var cancellables = Set<AnyCancellable>()
    var onPlayRequested: ((Translation, String) -> Void)?
    
    init(
        movie: ContentItem,
        useCase: GetMovieDetailUseCaseProtocol,
        favoritesUseCase: FavoritesUseCase,
        progressManager: PlaybackProgressManagerProtocol
    ) {
        self.movie = movie
        self.useCase = useCase
        self.favoritesUseCase = favoritesUseCase
        self.progressManager = progressManager
        
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
            let (detailData, translationsData) = try await useCase.fetchDetail(movie: movie, isSeries: false)
            
            await MainActor.run {
                self.detail = detailData
                self.translations = translationsData
            }
        } catch {
            print("Error loading movie detail: \(error)")
        }
    }

    func refreshProgress() {
        isWatched = progressManager.isWatched(movieId: movie.id, season: 0, episode: 0)
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
    
    func play(translation: Translation) {
        guard let url = translation.bestURL else { return }
        onPlayRequested?(translation, url)
    }
}
