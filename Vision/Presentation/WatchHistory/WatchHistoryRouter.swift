import Foundation

protocol WatchHistoryRouterProtocol: AnyObject {
    func navigateToDetail(for item: ContentItem)
}

final class WatchHistoryRouter: WatchHistoryRouterProtocol {
    private weak var coordinator: AppCoordinatorProtocol?
    init(coordinator: AppCoordinatorProtocol) { self.coordinator = coordinator }
    func navigateToDetail(for item: ContentItem) { coordinator?.showDetail(for: item) }
}
