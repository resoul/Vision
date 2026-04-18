import UIKit

final class MoviesPosterCollectionCell: UICollectionViewCell {
    static let reuseID = "MoviesPosterCollectionCell"

    private let posterImageView = UIImageView()
    private let topGradientView = GradientView(
        colors: [
            UIColor.black.withAlphaComponent(0.45).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ],
        locations: [0, 0.35, 1.0]
    )
    private let bottomGradientView = GradientView(
        colors: [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ],
        locations: [0.5, 1.0]
    )

    private let adsBadgeView = BadgeView(text: "ADS", background: UIColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 0.92), font: .systemFont(ofSize: 14, weight: .heavy))
    private let seriesBadgeView = BadgeView(text: "SERIES", background: UIColor(red: 0.20, green: 0.50, blue: 0.90, alpha: 0.88), font: .systemFont(ofSize: 15, weight: .bold))

    private var movie: ContentItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous

        contentView.addSubview(posterImageView)
        contentView.addSubview(topGradientView)
        contentView.addSubview(bottomGradientView)
        contentView.addSubview(adsBadgeView)
        contentView.addSubview(seriesBadgeView)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        topGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        adsBadgeView.translatesAutoresizingMaskIntoConstraints = false
        seriesBadgeView.translatesAutoresizingMaskIntoConstraints = false

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            topGradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bottomGradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            adsBadgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            adsBadgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            seriesBadgeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            seriesBadgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        backgroundColor = UIColor(white: 0.2, alpha: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelPoster()
        movie = nil
    }

    func configure(movie: ContentItem) {
        self.movie = movie
        adsBadgeView.isHidden = !movie.isAdIn
        seriesBadgeView.isHidden = !movie.type.isSeries

        let placeholder = PlaceholderArt.generate(for: movie, size: CGSize(width: 440, height: 626))
        posterImageView.setPoster(url: movie.posterURL, placeholder: placeholder)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let willBeFocused = (context.nextFocusedView === self)
        coordinator.addCoordinatedAnimations {
            self.transform = willBeFocused ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
            self.backgroundColor = willBeFocused ? .systemBlue : UIColor(white: 0.20, alpha: 1.0)
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = willBeFocused ? 0.45 : 0.0
            self.layer.shadowRadius = willBeFocused ? 18 : 0
            self.layer.shadowOffset = willBeFocused ? CGSize(width: 0, height: 14) : .zero
            self.layer.borderWidth = willBeFocused ? 2 : 0
            self.layer.borderColor = UIColor.white.cgColor
        }
    }
}

private final class GradientView: UIView {
    private let colors: [CGColor]
    private let locations: [NSNumber]

    init(colors: [CGColor], locations: [NSNumber]) {
        self.colors = colors
        self.locations = locations
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = colors
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

private final class BadgeView: UIView {
    private let label = UILabel()

    init(text: String, background: UIColor, font: UIFont) {
        super.init(frame: .zero)

        layer.cornerRadius = 6
        layer.cornerCurve = .continuous
        self.backgroundColor = background

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = font

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
