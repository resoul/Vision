import UIKit

protocol WatchHistoryViewProtocol: AnyObject {
    func showEmpty()
    func showContent(_ items: [ContentItem])
    func showError(_ message: String)
}

// Отдельный layout — не коллекция постеров,
// а свой дизайн (список с прогрессом для WatchHistory, сетка для Favorites)
final class WatchHistoryViewController: UIViewController {

    var presenter: WatchHistoryPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        presenter?.viewDidLoad()
    }
}

extension WatchHistoryViewController: WatchHistoryViewProtocol {
    func showEmpty()  { /* TODO: empty state */ }
    func showContent(_ items: [ContentItem]) { /* TODO: кастомный layout */ }
    func showError(_ message: String) { /* TODO */ }
}
