// MARK: - Protocol

protocol DependencyContainerProtocol {
    var contentRepository: ContentRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }
    var themeManager: ThemeManagerProtocol { get }
    var languageManager: LanguageManagerProtocol { get }
}

// MARK: - Implementation

final class AppDependencyContainer: DependencyContainerProtocol {

    lazy var contentRepository: ContentRepositoryProtocol = ContentService()
    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsService()
    lazy var themeManager: ThemeManagerProtocol = ThemeManager()
    lazy var languageManager: LanguageManagerProtocol = LanguageManager()
}
