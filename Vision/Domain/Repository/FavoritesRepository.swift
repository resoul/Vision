import Foundation
import Combine

protocol FavoritesRepository {
    func getAll() async throws -> [ContentItem]
    func isFavorite(id: Int) async throws -> Bool
    func add(_ item: ContentItem) async throws
    func remove(id: Int) async throws
    
    // For reactive updates
    var favoritesPublisher: AnyPublisher<[ContentItem], Never> { get }
}
