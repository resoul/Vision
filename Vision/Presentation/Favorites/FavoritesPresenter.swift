import Foundation

protocol FavoritesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectItem(_ item: ContentItem)
}

protocol FavoritesInteractorOutputProtocol: AnyObject {
    func didFetchContent(_ items: [ContentItem])
    func didFailWithError(_ error: Error)
}

final class FavoritesPresenter: FavoritesPresenterProtocol {

    private weak var view: FavoritesViewProtocol?
    private let interactor: FavoritesInteractorProtocol
    private let router: FavoritesRouterProtocol

    init(
        view: FavoritesViewProtocol,
        interactor: FavoritesInteractorProtocol,
        router: FavoritesRouterProtocol
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

extension FavoritesPresenter: FavoritesInteractorOutputProtocol {
    func didFetchContent(_ items: [ContentItem]) {
        items.isEmpty ? view?.showEmpty() : view?.showContent(items)
    }
    func didFailWithError(_ error: Error) { view?.showError(error.localizedDescription) }
}
