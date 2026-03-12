import Combine
import Foundation

final class SettingsViewModel: ObservableObject {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded(SettingsData)
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var currentTheme: Theme = .dark
    @Published private(set) var currentStyle: ThemeStyle = Theme.dark.style
    @Published private(set) var currentLanguage: AppLanguage = .russian

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let themeManager: ThemeManagerProtocol
    private let languageManager: LanguageManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        settingsRepository: SettingsRepositoryProtocol,
        themeManager: ThemeManagerProtocol,
        languageManager: LanguageManagerProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.themeManager = themeManager
        self.languageManager = languageManager
        bindManagers()
    }

    // MARK: - Actions (UDF)

    func viewDidLoad() {
        loadSettings()
    }

    func didToggleAutoplay(_ isOn: Bool) {
        guard case .loaded(var data) = state else { return }
        data.isAutoplayEnabled = isOn
        state = .loaded(data)
        settingsRepository.saveAutoplay(isOn)
    }

    func didSelectTheme(_ theme: Theme) {
        themeManager.apply(theme)
        // currentTheme и currentStyle обновятся через bind автоматически
    }

    func didSelectLanguage(_ language: AppLanguage) {
        languageManager.select(language)
        // currentLanguage обновится через bind
        // AppCoordinator подписан отдельно — вызовет restartStack()
    }

    // MARK: - Private

    private func bindManagers() {
        themeManager.currentTheme
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTheme)

        themeManager.currentStyle
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStyle)

        languageManager.currentLanguage
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLanguage)
    }

    private func loadSettings() {
        state = .loading
        settingsRepository.fetchSettings { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): self?.state = .loaded(data)
                case .failure(let error): self?.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
