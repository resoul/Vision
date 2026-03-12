import UIKit
import Combine

protocol Coordinator: AnyObject {
    func start()
}

protocol AppCoordinatorProtocol: AnyObject {
    func show(_ destination: TabDestination, animated: Bool)
    func showSearch()
    func showSettings()
    func showDetail(for item: ContentItem)
}

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let factory: ModuleFactoryProtocol
    private let languageManager: LanguageManagerProtocol

    private weak var appViewController: AppViewController?
    private var cancellables = Set<AnyCancellable>()

    init(
        window: UIWindow,
        factory: ModuleFactoryProtocol,
        languageManager: LanguageManagerProtocol
    ) {
        self.window = window
        self.factory = factory
        self.languageManager = languageManager
    }

    func start() {
        bindLanguage()
        buildApp()
    }

    // MARK: - Private

    private func buildApp() {
        let appVC = factory.makeAppModule(coordinator: self)
        appViewController = appVC as? AppViewController
        window.rootViewController = appVC
        window.makeKeyAndVisible()
    }

    private func bindLanguage() {
        languageManager.currentLanguage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.buildApp() }
            .store(in: &cancellables)
    }
}

extension AppCoordinator: AppCoordinatorProtocol {

    func show(_ destination: TabDestination, animated: Bool) {
        guard let appVC = appViewController else { return }
        let contentVC = factory.makeContentModule(for: destination, coordinator: self)
        appVC.showContent(contentVC, animated: animated)
    }

    func showSearch() {
        guard let appVC = appViewController else { return }
        let searchVC = factory.makeSearchModule(coordinator: self)
        appVC.presentModal(searchVC, onDismiss: nil)
    }

    func showSettings() {
        guard let appVC = appViewController else { return }
        let settingsVC = factory.makeSettingsModule()
        appVC.presentModal(settingsVC, onDismiss: nil)
    }

    func showDetail(for item: ContentItem) {
        guard let appVC = appViewController else { return }
        let detailVC = factory.makeDetailModule(item: item, coordinator: self)
        appVC.presentModal(detailVC, onDismiss: nil)
    }
}
