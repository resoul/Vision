import UIKit
import Combine

// MARK: - Protocol

protocol ThemeManagerProtocol {
    var currentStyle: AnyPublisher<ThemeStyle, Never> { get }
    var currentTheme: AnyPublisher<Theme, Never> { get }
    func apply(_ theme: Theme)
}

// MARK: - Implementation

final class ThemeManager: ThemeManagerProtocol {

    @Published private(set) var theme: Theme

    var currentTheme: AnyPublisher<Theme, Never> {
        $theme.eraseToAnyPublisher()
    }

    var currentStyle: AnyPublisher<ThemeStyle, Never> {
        $theme.map(\.style).eraseToAnyPublisher()
    }

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        let saved = storage.string(forKey: "app.theme").flatMap { Theme(rawValue: $0) }
        self.theme = saved ?? .dark
    }

    func apply(_ theme: Theme) {
        self.theme = theme
        storage.set(theme.rawValue, forKey: "app.theme")

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = theme.userInterfaceStyle }
    }
}
