import UIKit
import AsyncDisplayKit
import Filmix

// MARK: - Protocol

// MARK: - MoviesViewController

final class MoviesViewController: ASDKViewController<ASCollectionNode> {

    var viewModel: MoviesViewModel? {
        didSet { startIfNeeded() }
    }

    private var didStart = false
    private var preferredIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var movies: [Movie] = []

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.color = .white
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        l.textColor = UIColor(white: 0.6, alpha: 1)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var collectionNode: ASCollectionNode {
        node
    }

    override init() {
        let layout = UICollectionViewFlowLayout()

        let available = UIScreen.main.bounds.width - 160
        let spacing   = 28.0 * 4
        let w = floor((available - spacing) / 5)
        let h = floor(w * 313 / 220)

        layout.itemSize = CGSize(width: w, height: h)
        layout.minimumInteritemSpacing = 28
        layout.minimumLineSpacing = 44
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 30, left: 80, bottom: 80, right: 80)

        super.init(node: ASCollectionNode(collectionViewLayout: layout))

        collectionNode.backgroundColor = .black
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.view.remembersLastFocusedIndexPath = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])

        startIfNeeded()
    }

    private func startIfNeeded() {
        guard isViewLoaded, !didStart, let viewModel else { return }
        didStart = true
        bindViewModel(viewModel)
        viewModel.onViewDidLoad()
    }

    private func bindViewModel(_ viewModel: MoviesViewModel) {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.errorLabel.isHidden = true
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
        viewModel.onMoviesChanged = { [weak self] movies in
            guard let self else { return }
            self.movies = movies
            self.collectionNode.reloadData()
        }
        viewModel.onMoviesAppended = { [weak self] movies in
            guard let self else { return }
            guard !movies.isEmpty else { return }
            let startIndex = self.movies.count
            self.movies.append(contentsOf: movies)
            let indexPaths = (startIndex ..< self.movies.count).map { IndexPath(item: $0, section: 0) }
            self.collectionNode.performBatchUpdates({
                self.collectionNode.insertItems(at: indexPaths)
            }, completion: nil)
        }
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
        }
    }
}

// MARK: - ASCollectionDataSource, ASCollectionDelegate

extension MoviesViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: ASCollectionView, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        MovieCellNode(movie: movies[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectItem(at: indexPath.item)
    }

    func collectionView(
        _ collectionView: ASCollectionView,
        willDisplay cell: ASCellNode,
        forItemAt indexPath: IndexPath
    ) {
        viewModel?.loadNextPageIfNeeded(currentIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        true
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        preferredIndexPath
    }

    func collectionView(
        _ collectionView: UICollectionView,
        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext
    ) -> Bool {
        true
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        if let next = context.nextFocusedIndexPath {
            preferredIndexPath = next
        }
    }
}

// MARK: - MovieCellNode

extension Movie {
    var accentColor: UIColor {
        let palette: [UIColor] = [
            UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1),
            UIColor(red: 0.10, green: 0.28, blue: 0.55, alpha: 1),
            UIColor(red: 0.35, green: 0.12, blue: 0.45, alpha: 1),
            UIColor(red: 0.08, green: 0.35, blue: 0.28, alpha: 1),
            UIColor(red: 0.50, green: 0.10, blue: 0.10, alpha: 1)
        ]

        return palette[abs(id) % palette.count]
    }
}

final class MovieCellNode: ASCellNode {

    private let posterNode      = ASNetworkImageNode()
    private let topScrimNode    = ASDisplayNode()
    private let bottomScrimNode = ASDisplayNode()

    private let adsBadgeNode    = ASDisplayNode()
    private let adsTextNode     = ASTextNode()

    private let seriesBadgeNode = ASDisplayNode()
    private let seriesTextNode  = ASTextNode()

    private let movie: Movie

    init(movie: Movie) {
        self.movie = movie
        super.init()
        automaticallyManagesSubnodes = true
        clipsToBounds = true
        cornerRadius  = 14
        cornerRoundingType = .defaultSlowCALayer

        setupPoster()
        setupScrims()
        setupBadges()
        applyMovieData()
    }

    private func setupPoster() {
        posterNode.contentMode = .scaleAspectFill
        posterNode.clipsToBounds = true
        posterNode.defaultImage = PlaceholderArt.generate(
            for: movie,
            size: CGSize(width: 440, height: 626)
        )
        if !movie.posterURL.isEmpty {
            posterNode.url = URL(string: movie.posterURL)
        }
    }

    private func setupScrims() {
        topScrimNode.setViewBlock {
            let v = UIView()
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.black.withAlphaComponent(0.45).cgColor,
                UIColor.clear.cgColor,
                UIColor.clear.cgColor
            ]
            gradient.locations = [0, 0.35, 1.0]
            v.layer.addSublayer(gradient)
            return v
        }

        bottomScrimNode.setViewBlock {
            let v = UIView()
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.55).cgColor
            ]
            gradient.locations = [0.5, 1.0]
            v.layer.addSublayer(gradient)
            return v
        }
    }

    private func setupBadges() {
        adsBadgeNode.backgroundColor = UIColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 0.92)
        adsBadgeNode.cornerRadius = 6
        adsBadgeNode.cornerRoundingType = .defaultSlowCALayer
        adsTextNode.attributedText = NSAttributedString(
            string: "ADS",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .heavy),
                .foregroundColor: UIColor.white
            ]
        )

        seriesBadgeNode.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.88)
        seriesBadgeNode.cornerRadius = 6
        seriesBadgeNode.cornerRoundingType = .defaultSlowCALayer
        seriesTextNode.attributedText = NSAttributedString(
            string: "SERIES",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        )
    }

    private func applyMovieData() {
        adsBadgeNode.isHidden    = !movie.isAdIn
        seriesBadgeNode.isHidden = !movie.type.isSeries
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let size = constrainedSize.max

        posterNode.style.preferredSize      = size
        topScrimNode.style.preferredSize    = size
        bottomScrimNode.style.preferredSize = size

        let adsInner = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [adsTextNode]
        )
        let adsPadded = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6),
            child: adsInner
        )
        let adsBadge = ASBackgroundLayoutSpec(child: adsPadded, background: adsBadgeNode)
        adsBadge.style.layoutPosition = CGPoint(x: size.width - 70, y: 10)

        let seriesInner = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [seriesTextNode]
        )
        let seriesPadded = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7),
            child: seriesInner
        )
        let seriesBadge = ASBackgroundLayoutSpec(child: seriesPadded, background: seriesBadgeNode)
        seriesBadge.style.layoutPosition = CGPoint(x: size.width - 90, y: size.height - 32)

        let absolute = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [
            posterNode,
            topScrimNode,
            bottomScrimNode,
            adsBadge,
            seriesBadge
        ])

        return absolute
    }

    override func canBecomeFocused() -> Bool { true }
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool { true }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let willBeFocused = (context.nextFocusedView === view)
        coordinator.addCoordinatedAnimations {
            self.view.transform = willBeFocused ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
            self.backgroundColor = willBeFocused ? .systemBlue : UIColor(white: 0.20, alpha: 1.0)
            self.shadowColor = UIColor.black.cgColor
            self.shadowOpacity = willBeFocused ? 0.45 : 0.0
            self.shadowRadius = willBeFocused ? 18 : 0
            self.shadowOffset = willBeFocused ? CGSize(width: 0, height: 14) : .zero
            self.layer.borderWidth = willBeFocused ? 2 : 0
            self.layer.borderColor = UIColor.white.cgColor
        }
    }
}

// MARK: - PlaceholderArt

enum PlaceholderArt {
    static func generate(for movie: Movie, size: CGSize = CGSize(width: 880, height: 1252)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        let accent = movie.accentColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        accent.getRed(&r, green: &g, blue: &b, alpha: nil)

        let topColor = UIColor(red: r * 0.9 + 0.05, green: g * 0.9 + 0.03, blue: b * 0.9 + 0.05, alpha: 1).cgColor
        let midColor = UIColor(red: r * 0.5 + 0.04, green: g * 0.5 + 0.03, blue: b * 0.5 + 0.06, alpha: 1).cgColor
        let botColor = UIColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1).cgColor
        let grad = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [topColor, midColor, botColor] as CFArray,
            locations: [0, 0.5, 1.0]
        )!
        ctx.drawLinearGradient(grad, start: .zero, end: CGPoint(x: size.width * 0.3, y: size.height), options: [])

        ctx.saveGState()
        let orbRect = CGRect(x: -size.width * 0.1, y: -size.height * 0.05, width: size.width * 0.9, height: size.height * 0.65)
        let orbGrad = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor(red: r, green: g, blue: b, alpha: 0.30).cgColor,
                     UIColor(red: r, green: g, blue: b, alpha: 0.0).cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.addEllipse(in: orbRect)
        ctx.clip()
        ctx.drawRadialGradient(
            orbGrad,
            startCenter: CGPoint(x: orbRect.midX, y: orbRect.midY),
            startRadius: 0,
            endCenter: CGPoint(x: orbRect.midX, y: orbRect.midY),
            endRadius: max(orbRect.width, orbRect.height) / 2,
            options: []
        )
        ctx.restoreGState()

        ctx.setStrokeColor(UIColor(white: 1, alpha: 0.04).cgColor)
        ctx.setLineWidth(1)
        let step: CGFloat = size.width / 6
        for i in 0...6 {
            ctx.move(to: CGPoint(x: step * CGFloat(i), y: 0))
            ctx.addLine(to: CGPoint(x: step * CGFloat(i), y: size.height))
        }
        ctx.strokePath()

        ctx.saveGState()
        let smallOrb = CGRect(x: size.width * 0.55, y: size.height * 0.6, width: size.width * 0.8, height: size.width * 0.8)
        let sg = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor(red: r * 0.7, green: g * 0.7, blue: b * 0.7, alpha: 0.18).cgColor, UIColor.clear.cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.addEllipse(in: smallOrb)
        ctx.clip()
        ctx.drawRadialGradient(
            sg,
            startCenter: CGPoint(x: smallOrb.midX, y: smallOrb.midY),
            startRadius: 0,
            endCenter: CGPoint(x: smallOrb.midX, y: smallOrb.midY),
            endRadius: max(smallOrb.width, smallOrb.height) / 2,
            options: []
        )
        ctx.restoreGState()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
// MARK: - MoviesViewModel

@MainActor
final class MoviesViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onMoviesChanged: (([Movie]) -> Void)?
    var onMoviesAppended: (([Movie]) -> Void)?
    var onError: ((String) -> Void)?

    private let baseListURL: String
    private let basePageURL: String
    private var movies: [Movie] = []
    private var isLoading = false
    private var hasMore = true
    private var currentPage = 1

    init(basePath: String) {
        self.baseListURL = "https://filmix.my/\(basePath)/"
        self.basePageURL = "https://filmix.my/\(basePath)/pages/"
    }

    func onViewDidLoad() {
        guard movies.isEmpty else { return }
        loadInitial()
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard hasMore, !isLoading else { return }
        let threshold = max(0, movies.count - 10)
        guard currentIndex >= threshold else { return }
        loadNext()
    }

    func didSelectItem(at index: Int) {
        guard index < movies.count else { return }
        // TODO: Routing to detail (MVVM-Coordinator)
    }

    // MARK: - Private

    private func loadInitial() {
        isLoading = true
        onLoadingChanged?(true)
        currentPage = 1

        Task {
            do {
                let page = try await Filmix.shared.fetchMoviePage.execute(url: URL(string: baseListURL))
                let newMovies = page.movies
                movies = newMovies
                hasMore = !newMovies.isEmpty
                isLoading = false
                onLoadingChanged?(false)
                onMoviesChanged?(newMovies)
            } catch {
                isLoading = false
                onLoadingChanged?(false)
                onError?(error.localizedDescription)
            }
        }
    }

    private func loadNext() {
        isLoading = true
        let nextPage = currentPage + 1
        let urlString = "\(basePageURL)\(nextPage)/"

        Task {
            do {
                let page = try await Filmix.shared.fetchMoviePage.execute(url: URL(string: urlString))
                let newMovies = page.movies
                if newMovies.isEmpty { hasMore = false }
                currentPage = nextPage
                movies.append(contentsOf: newMovies)
                isLoading = false
                onMoviesAppended?(newMovies)
            } catch {
                isLoading = false
                onError?(error.localizedDescription)
            }
        }
    }
}

