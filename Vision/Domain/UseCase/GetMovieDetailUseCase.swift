import Foundation

protocol GetMovieDetailUseCaseProtocol {
    func fetchDetail(movie: ContentItem, isSeries: Bool) async throws -> (ContentDetail, [Translation])
}

final class GetMovieDetailUseCase: GetMovieDetailUseCaseProtocol {
    private let repository: FilmixMovieRepositoryProtocol
    
    init(repository: FilmixMovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchDetail(movie: ContentItem, isSeries: Bool) async throws -> (ContentDetail, [Translation]) {
        let detail = try await repository.fetchDetail(path: movie.movieURL)
        guard !detail.isNotMovie else {
            // Restricted content: show metadata only, skip player translations.
            return (detail, [])
        }

        let translations = try await repository.fetchTranslations(postId: movie.id, isSeries: isSeries)
        return (detail, translations)
    }
}
