import Foundation

protocol WatchHistoryPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectItem(_ item: ContentItem)
}

protocol WatchHistoryInteractorOutputProtocol: AnyObject {
    func didFetchContent(_ items: [ContentItem])
    func didFailWithError(_ error: Error)
}

final class WatchHistoryPresenter: WatchHistoryPresenterProtocol {

    private weak var view: WatchHistoryViewProtocol?
    private let interactor: WatchHistoryInteractorProtocol
    private let router: WatchHistoryRouterProtocol

    init(
        view: WatchHistoryViewProtocol,
        interactor: WatchHistoryInteractorProtocol,
        router: WatchHistoryRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() { interactor.fetchContent() }

    func didSelectItem(_ item: ContentItem) {
        router.navigateToDetail(for: item)
    }
}

extension WatchHistoryPresenter: WatchHistoryInteractorOutputProtocol {
    func didFetchContent(_ items: [ContentItem]) {
        items.isEmpty ? view?.showEmpty() : view?.showContent(items)
    }
    func didFailWithError(_ error: Error) { view?.showError(error.localizedDescription) }
}
