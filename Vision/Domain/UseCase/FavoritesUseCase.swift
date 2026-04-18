import Foundation
import Combine

final class FavoritesUseCase {
    private let repository: FavoritesRepository
    
    var favoritesPublisher: AnyPublisher<[ContentItem], Never> {
        repository.favoritesPublisher
    }
    
    init(repository: FavoritesRepository) {
        self.repository = repository
    }
    
    func getAll() async throws -> [ContentItem] {
        try await repository.getAll()
    }
    
    func isFavorite(id: Int) async throws -> Bool {
        try await repository.isFavorite(id: id)
    }
    
    func toggle(_ item: ContentItem) async throws {
        if try await repository.isFavorite(id: item.id) {
            try await repository.remove(id: item.id)
        } else {
            try await repository.add(item)
        }
    }
}
