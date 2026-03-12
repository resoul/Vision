import Foundation

struct ContentPage {
    let items: [ContentItem]
    let nextPageURL: URL?
}

// MARK: - Repository Protocols

protocol ContentRepositoryProtocol {
    func fetchPage(url: URL?, completion: @escaping (Result<ContentPage, Error>) -> Void)
}

protocol SettingsRepositoryProtocol {
    func fetchSettings(completion: @escaping (Result<SettingsData, Error>) -> Void)
    func saveAutoplay(_ isEnabled: Bool)
}
