import UIKit
import Combine
import TabBar

// MARK: - AppViewController

final class AppViewController: UIViewController {

    var viewModel: AppViewModel? {
        didSet { bindViewModelIfNeeded() }
    }

    private let tabBarView = TabBarView(configuration: TabBarConfiguration(items: []), searchTitle: L10n.Tab.search)
    private var tabBarHeightConstraint: NSLayoutConstraint!

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var currentChildVC: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    private let themeStyle: AnyPublisher<ThemeStyle, Never>?

    // MARK: - Init

    init(themeStyle: AnyPublisher<ThemeStyle, Never>? = nil) {
        self.themeStyle = themeStyle
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindTheme()
        bindViewModelIfNeeded()
        viewModel?.onViewDidLoad()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [tabBarView]
    }

    // MARK: - Menu button (tvOS remote)

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.contains(where: { $0.type == .menu }),
              let modal = presentedViewController else {
            super.pressesBegan(presses, with: event)
            return
        }
        modal.dismiss(animated: true) { [weak self] in
            self?.returnFocusToTabBar()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.11, alpha: 1)

        view.addSubview(contentView)
        view.addSubview(tabBarView)
        tabBarView.delegate = self

        tabBarHeightConstraint = tabBarView.heightAnchor.constraint(
            equalToConstant: tabBarView.collapsedHeight
        )

        NSLayoutConstraint.activate([
            tabBarView.topAnchor.constraint(equalTo: view.topAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarHeightConstraint,

            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Child VC swap (crossfade)

    private func swapContent(to newVC: UIViewController, animated: Bool) {
        let oldVC = currentChildVC
        newVC.additionalSafeAreaInsets.top = tabBarHeightConstraint.constant

        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        newVC.view.alpha = animated ? 0 : 1
        contentView.addSubview(newVC.view)
        pinEdges(newVC.view, to: contentView)
        newVC.didMove(toParent: self)

        if animated {
            UIView.animate(withDuration: 0.25, animations: { newVC.view.alpha = 1 }) { _ in
                oldVC?.willMove(toParent: nil)
                oldVC?.view.removeFromSuperview()
                oldVC?.removeFromParent()
            }
        } else {
            oldVC?.willMove(toParent: nil)
            oldVC?.view.removeFromSuperview()
            oldVC?.removeFromParent()
        }
        currentChildVC = newVC
    }

    // MARK: - Theme

    private func bindTheme() {
        themeStyle?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in self?.view.backgroundColor = style.background }
            .store(in: &cancellables)
    }

    // MARK: - Bindings

    private func bindViewModelIfNeeded() {
        guard isViewLoaded, let viewModel else { return }
        viewModel.onConfigureTabBar = { [weak self] configuration in
            self?.tabBarView.apply(configuration: configuration)
        }
        viewModel.onUpdateTabBarHeight = { [weak self] hasGenres in
            self?.updateTabBarHeight(hasGenres: hasGenres)
        }
    }

    // MARK: - Helpers

    private func updateTabBarHeight(hasGenres: Bool) {
        let target: CGFloat = hasGenres
            ? tabBarView.expandedHeight
            : tabBarView.collapsedHeight
        guard tabBarHeightConstraint.constant != target else { return }
        tabBarHeightConstraint.constant = target
        currentChildVC?.additionalSafeAreaInsets.top = target
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        }
    }

    private func pinEdges(_ child: UIView, to container: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: container.topAnchor),
            child.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }

    func showContent(_ viewController: UIViewController, animated: Bool) {
        swapContent(to: viewController, animated: animated)
    }

    func presentModal(_ viewController: UIViewController, onDismiss: (() -> Void)? = nil) {
        tabBarView.lockSettingsFocus()
        if view.window != nil {
            present(viewController, animated: true)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.present(viewController, animated: true)
            }
        }
    }
}

// MARK: - TabBarDelegate

extension AppViewController: TabBarDelegate {
    func tabBar(_ tabBar: TabBarView, didSelectItem item: TabItem) {
        viewModel?.didSelectItem(item)
    }

    func tabBar(_ tabBar: TabBarView, didSelectGenre genre: GenreItem, inItem item: TabItem) {
        viewModel?.didSelectGenre(genre, in: item)
    }

    func tabBarDidSelectSearch(_ tabBar: TabBarView) {
        viewModel?.didSelectSearch()
    }

    func tabBarDidSelectSettings(_ tabBar: TabBarView) {
        viewModel?.didSelectSettings()
    }
}

// MARK: - Focus restoration

extension AppViewController {
    func returnFocusToTabBar() {
        tabBarView.unlockSettingsFocus()
    }
}
// MARK: - AppViewModel

@MainActor
final class AppViewModel {

    var onConfigureTabBar: ((TabBarConfiguration) -> Void)?
    var onUpdateTabBarHeight: ((Bool) -> Void)?

    private let coordinator: AppCoordinatorProtocol
    private var categories: [Category] = []

    init(coordinator: AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        categories = Category.all
        onConfigureTabBar?(tabBarConfig(from: categories))

        if let first = categories.first {
            coordinator.show(destination(for: first, genreURL: nil), animated: false)
        }
    }

    func didSelectItem(_ item: TabItem) {
        guard let category = category(forItemID: item.id) else { return }
        onUpdateTabBarHeight?(!category.genres.isEmpty)
        coordinator.show(destination(for: category, genreURL: nil), animated: true)
    }

    func didSelectGenre(_ genre: GenreItem, in item: TabItem) {
        guard let category = category(forItemID: item.id) else { return }
        coordinator.show(destination(for: category, genreURL: genre.id), animated: true)
    }

    func didSelectSearch() {
        coordinator.showSearch()
    }

    func didSelectSettings() {
        coordinator.showSettings()
    }

    // MARK: - Mapping Category → TabBarConfiguration

    private func tabBarConfig(from categories: [Category]) -> TabBarConfiguration {
        let items = categories.map { category in
            TabItem(
                id: category.url,
                title: category.title,
                icon: category.icon,
                genres: category.genres.map { GenreItem(id: $0.url, title: $0.title) }
            )
        }
        return TabBarConfiguration(items: items)
    }

    // MARK: - Mapping Category → TabDestination

    private func destination(for category: Category, genreURL: String?) -> TabDestination {
        switch category.kind {
        case .favorites:    return .favorites
        case .watchHistory: return .watchHistory
        case .regular:
            if category.url.contains("/film/")  { return .movies(genreURL: genreURL) }
            if category.url.contains("/seria/") { return .series(genreURL: genreURL) }
            if category.url.contains("/mults/") { return .cartoons(genreURL: genreURL) }
            return .home
        }
    }

    // MARK: - Helpers

    private func category(forItemID id: String) -> Category? {
        categories.first { $0.url == id }
    }
}

