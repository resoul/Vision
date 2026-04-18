import Foundation

protocol SearchUseCaseProtocol {
    func search(query: String) async throws -> [ContentItem]
}

final class SearchUseCase: SearchUseCaseProtocol {
    private let repository: FilmixMovieRepositoryProtocol
    
    init(repository: FilmixMovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func search(query: String) async throws -> [ContentItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let page = try await repository.search(query: query)
        return page.items
    }
}
