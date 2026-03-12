import UIKit

// MARK: - Protocol

protocol ModuleFactoryProtocol {
    func makeAppModule(coordinator: AppCoordinatorProtocol) -> UIViewController
    func makeContentModule(for destination: TabDestination, coordinator: AppCoordinatorProtocol) -> UIViewController
    func makeSettingsModule() -> UIViewController
    func makeSearchModule(coordinator: AppCoordinatorProtocol) -> UIViewController
    func makeDetailModule(item: ContentItem, coordinator: AppCoordinatorProtocol) -> UIViewController
}

// MARK: - ModuleFactory

final class ModuleFactory: ModuleFactoryProtocol {

    private let container: DependencyContainerProtocol

    init(container: DependencyContainerProtocol) {
        self.container = container
    }

    // MARK: - App container

    func makeAppModule(coordinator: AppCoordinatorProtocol) -> UIViewController {
        let appVC = AppViewController(themeStyle: container.themeManager.currentStyle)
        let viewModel = AppViewModel(coordinator: coordinator)
        appVC.viewModel = viewModel
        return appVC
    }

    // MARK: - Content modules

    func makeContentModule(
        for destination: TabDestination,
        coordinator: AppCoordinatorProtocol
    ) -> UIViewController {
        switch destination {
        case .home:
            return makeMoviesModule(basePath: "film", coordinator: coordinator)
        case .movies(_):
            return makeMoviesModule(basePath: "film", coordinator: coordinator)
        case .series(_):
            return makeMoviesModule(basePath: "seria", coordinator: coordinator)
        case .cartoons(_):
            return makeMoviesModule(basePath: "mults", coordinator: coordinator)
        case .favorites:
            return makeFavoritesModule(coordinator: coordinator)
        case .watchHistory:
            return makeWatchHistoryModule(coordinator: coordinator)
        }
    }

    // MARK: - Modal

    func makeSettingsModule() -> UIViewController {
        let viewModel = SettingsViewModel(
            settingsRepository: container.settingsRepository,
            themeManager: container.themeManager,
            languageManager: container.languageManager
        )
        return SettingsViewController(viewModel: viewModel)
    }

    func makeSearchModule(coordinator: AppCoordinatorProtocol) -> UIViewController {
        // TODO: SearchModule
        return UIViewController()
    }

    func makeDetailModule(item: ContentItem, coordinator: AppCoordinatorProtocol) -> UIViewController {
        // TODO: DetailModule
        return UIViewController()
    }

    // MARK: - Private builders

    private func makeMoviesModule(basePath: String, coordinator: AppCoordinatorProtocol) -> UIViewController {
        _ = coordinator
        let vc = MoviesViewController()
        let viewModel = MoviesViewModel(basePath: basePath)
        vc.viewModel = viewModel
        return vc
    }

    private func makeFavoritesModule(coordinator: AppCoordinatorProtocol) -> UIViewController {
        let vc = FavoritesViewController()
        let router = FavoritesRouter(coordinator: coordinator)
        let interactor = FavoritesInteractor(contentRepository: container.contentRepository)
        let presenter = FavoritesPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        interactor.presenter = presenter
        return vc
    }

    private func makeWatchHistoryModule(coordinator: AppCoordinatorProtocol) -> UIViewController {
        let vc = WatchHistoryViewController()
        let router = WatchHistoryRouter(coordinator: coordinator)
        let interactor = WatchHistoryInteractor(contentRepository: container.contentRepository)
        let presenter = WatchHistoryPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        interactor.presenter = presenter
        return vc
    }
}
