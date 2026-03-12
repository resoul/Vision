import Foundation

final class ContentService: ContentRepositoryProtocol {
    func fetchPage(url: URL?, completion: @escaping (Result<ContentPage, any Error>) -> Void) {
        
    }
    
    func fetchCatalog(completion: @escaping (Result<[ContentItem], Error>) -> Void) {
        // TODO: реализация сетевого слоя
    }
}

// MARK: - Settings Service

final class SettingsService: SettingsRepositoryProtocol {
    func fetchSettings(completion: @escaping (Result<SettingsData, Error>) -> Void) {
        // TODO: читать из UserDefaults / remote config
    }

    func saveAutoplay(_ isEnabled: Bool) {
        // TODO: сохранять в UserDefaults
    }
}
