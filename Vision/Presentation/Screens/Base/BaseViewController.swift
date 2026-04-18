import UIKit
import Combine

class BaseViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    let themeManager: ThemeManagerProtocol
    let languageManager: LanguageManagerProtocol
    let fontSettingsManager: FontSettingsManagerProtocol
    
    init(
        themeManager: ThemeManagerProtocol,
        languageManager: LanguageManagerProtocol,
        fontSettingsManager: FontSettingsManagerProtocol
    ) {
        self.themeManager = themeManager
        self.languageManager = languageManager
        self.fontSettingsManager = fontSettingsManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseSubscriptions()
    }
    
    private func setupBaseSubscriptions() {
        themeManager.currentStyle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                self?.applyStyle(style)
            }
            .store(in: &cancellables)
            
        languageManager.currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.applyLanguage(language)
            }
            .store(in: &cancellables)
            
        fontSettingsManager.currentFamily
            .receive(on: DispatchQueue.main)
            .sink { [weak self] family in
                self?.applyFont(family)
            }
            .store(in: &cancellables)
    }
    
    func applyStyle(_ style: ThemeStyle) {
        view.backgroundColor = style.background
    }
    
    func applyLanguage(_ language: AppLanguage) {
        // Overridden by subclasses to update localized strings
    }
    
    func applyFont(_ family: FontFamily) {
        // Overridden by subclasses to update typography
    }
}
