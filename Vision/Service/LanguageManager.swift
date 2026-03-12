import Foundation
import Combine

// MARK: - Protocol

protocol LanguageManagerProtocol {
    var currentLanguage: AnyPublisher<AppLanguage, Never> { get }
    func select(_ language: AppLanguage)
}

// MARK: - Implementation

final class LanguageManager: LanguageManagerProtocol {

    @Published private(set) var language: AppLanguage

    var currentLanguage: AnyPublisher<AppLanguage, Never> {
        $language.eraseToAnyPublisher()
    }

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        let saved = storage.string(forKey: "app.language").flatMap { AppLanguage(rawValue: $0) }
        self.language = saved ?? .russian
        L10n.bundle = self.language.bundle
    }

    func select(_ language: AppLanguage) {
        guard language != self.language else { return }

        L10n.bundle = language.bundle
        storage.set(language.rawValue, forKey: "app.language")
        self.language = language
    }
}
