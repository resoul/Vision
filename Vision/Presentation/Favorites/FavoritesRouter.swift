import Foundation

protocol FavoritesRouterProtocol: AnyObject {
    func navigateToDetail(for item: ContentItem)
}

final class FavoritesRouter: FavoritesRouterProtocol {
    private weak var coordinator: AppCoordinatorProtocol?
    init(coordinator: AppCoordinatorProtocol) { self.coordinator = coordinator }
    func navigateToDetail(for item: ContentItem) { coordinator?.showDetail(for: item) }
}
