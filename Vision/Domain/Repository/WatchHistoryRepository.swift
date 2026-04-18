import Foundation
import Combine

protocol WatchHistoryRepository {
    func getHistory() async throws -> [ContentItem]
    func getInProgress() async throws -> [ContentItem]
    func saveProgress(_ item: ContentItem, episodeId: String?, position: Double, watched: Bool) async throws
    func touch(_ item: ContentItem) async throws
    func remove(id: Int) async throws
    func clearAll() async throws
    
    // For reactive updates
    var historyPublisher: AnyPublisher<[ContentItem], Never> { get }
}
