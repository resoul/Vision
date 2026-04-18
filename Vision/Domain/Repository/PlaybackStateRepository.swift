import Foundation

protocol PlaybackStateRepository {
    func getState(movieId: Int) async throws -> PlaybackState?
    func saveState(_ state: PlaybackState) async throws
    func clearState(movieId: Int) async throws
}
