import Foundation

protocol GetContentUseCaseProtocol {
    func fetchInitial(path: String) async throws -> [ContentItem]
    func fetchNextPage() async throws -> [ContentItem]
}

final class GetContentUseCase: GetContentUseCaseProtocol {
    private let repository: FilmixMovieRepositoryProtocol
    
    private var basePath: String = ""
    private var currentPage: Int = 1
    private var hasMore: Bool = true
    
    init(repository: FilmixMovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchInitial(path: String) async throws -> [ContentItem] {
        self.basePath = path
        self.currentPage = 1
        self.hasMore = true
        
        let page = try await repository.fetchPage(url: URL(string: path))
        self.hasMore = !page.items.isEmpty
        return page.items
    }
    
    func fetchNextPage() async throws -> [ContentItem] {
        guard hasMore else { return [] }
        
        let nextPage = currentPage + 1
        let urlString = "\(basePath)/pages/\(nextPage)/"
        
        let page = try await repository.fetchPage(url: URL(string: urlString))
        if page.items.isEmpty {
            hasMore = false
        } else {
            currentPage = nextPage
        }
        
        return page.items
    }
}
