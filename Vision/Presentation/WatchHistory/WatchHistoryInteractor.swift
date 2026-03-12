import Foundation

protocol WatchHistoryInteractorProtocol: AnyObject {
    func fetchContent()
}

final class WatchHistoryInteractor: WatchHistoryInteractorProtocol {

    weak var presenter: WatchHistoryInteractorOutputProtocol?
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
