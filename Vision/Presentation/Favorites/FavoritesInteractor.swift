import Foundation

protocol FavoritesInteractorProtocol: AnyObject {
    func fetchContent()
}

final class FavoritesInteractor: FavoritesInteractorProtocol {

    weak var presenter: FavoritesInteractorOutputProtocol?
    private let contentRepository: ContentRepositoryProtocol

    init(contentRepository: ContentRepositoryProtocol) {
        self.contentRepository = contentRepository
    }

    func fetchContent() {
//        contentRepository.fetchCatalog { [weak self] result in
//            switch result {
//            case .success(let items): self?.presenter?.didFetchContent(items)
//            case .failure(let error): self?.presenter?.didFailWithError(error)
//            }
//        }
    }
}
