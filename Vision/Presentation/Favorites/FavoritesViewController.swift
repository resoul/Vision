import UIKit

protocol FavoritesViewProtocol: AnyObject {
    func showEmpty()
    func showContent(_ items: [ContentItem])
    func showError(_ message: String)
}

// Отдельный layout — не коллекция постеров,
// а свой дизайн (список с прогрессом для WatchHistory, сетка для Favorites)
final class FavoritesViewController: UIViewController {

    var presenter: FavoritesPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        presenter?.viewDidLoad()
    }
}

extension FavoritesViewController: FavoritesViewProtocol {
    func showEmpty()  { /* TODO: empty state */ }
    func showContent(_ items: [ContentItem]) { /* TODO: кастомный layout */ }
    func showError(_ message: String) { /* TODO */ }
}
