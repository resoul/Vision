import UIKit

final class EpisodeBrowseCell: UICollectionViewCell {
    static let reuseID = "EpisodeBrowseCell"

    private let posterView = UIImageView()
    private let bottomContainer = UIView()
    private let episodeLabel = UILabel()
    private let titleLabel = UILabel()
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private let watchedIconView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    private var progressWidthConstraint: NSLayoutConstraint?
    private var baseTransform: CGAffineTransform = .identity
    private var baseBorderWidth: CGFloat = 0
    private var baseBorderColor: CGColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 18).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.cancelPoster()
    }

    func configure(item: EpisodeBrowseItem, style: ThemeStyle) {
        if item.posterURL.isEmpty {
            posterView.image = UIImage(systemName: "photo")
            posterView.tintColor = UIColor.white.withAlphaComponent(0.55)
            posterView.contentMode = .center
            posterView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        } else {
            posterView.contentMode = .scaleAspectFill
            posterView.backgroundColor = .clear
            posterView.setPoster(url: item.posterURL, placeholder: nil)
        }

        episodeLabel.text = String(format: L10n.Player.seasonEpisodeFormat, item.season, item.episode)
        titleLabel.text = item.title

        let progress = max(0, min(item.progress ?? 0, 1))
        progressTrackView.isHidden = progress <= 0.05
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: progress)
        progressWidthConstraint?.isActive = true

        watchedIconView.isHidden = !item.isWatched
        watchedIconView.tintColor = .systemGreen

        contentView.alpha = item.isWatched ? 0.65 : 1
        baseBorderWidth = item.isCurrent ? 6 : 0
        baseBorderColor = style.accent.cgColor
        contentView.layer.borderWidth = baseBorderWidth
        contentView.layer.borderColor = baseBorderColor
        baseTransform = item.isCurrent ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        transform = baseTransform

        progressFillView.backgroundColor = style.accent
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations {
            if self.isFocused {
                self.transform = self.baseTransform.concatenating(CGAffineTransform(scaleX: 1.08, y: 1.08))
                self.layer.shadowOpacity = 0.45
                self.layer.shadowRadius = 22
                self.layer.shadowOffset = CGSize(width: 0, height: 12)
                self.contentView.layer.borderWidth = max(self.contentView.layer.borderWidth, 2)
                self.contentView.layer.borderColor = UIColor.white.cgColor
            } else {
                self.transform = self.baseTransform
                self.layer.shadowOpacity = 0
                self.contentView.layer.borderWidth = self.baseBorderWidth
                self.contentView.layer.borderColor = self.baseBorderColor
            }
        }
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0

        posterView.translatesAutoresizingMaskIntoConstraints = false
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true

        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = UIColor.black.withAlphaComponent(0.55)

        episodeLabel.translatesAutoresizingMaskIntoConstraints = false
        episodeLabel.font = .systemFont(ofSize: 20, weight: .bold)
        episodeLabel.textColor = .white
        episodeLabel.numberOfLines = 1

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .regular)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        progressTrackView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        progressTrackView.layer.cornerRadius = 2

        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressFillView.layer.cornerRadius = 2

        watchedIconView.translatesAutoresizingMaskIntoConstraints = false
        watchedIconView.contentMode = .scaleAspectFit
        watchedIconView.tintColor = .systemGreen

        contentView.addSubview(posterView)
        contentView.addSubview(bottomContainer)
        bottomContainer.addSubview(episodeLabel)
        bottomContainer.addSubview(titleLabel)
        bottomContainer.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        contentView.addSubview(watchedIconView)

        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),

            bottomContainer.topAnchor.constraint(equalTo: posterView.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            episodeLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 10),
            episodeLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 12),
            episodeLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: episodeLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: episodeLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: episodeLabel.trailingAnchor),

            progressTrackView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            progressTrackView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            progressTrackView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
            progressTrackView.heightAnchor.constraint(equalToConstant: 4),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),

            watchedIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            watchedIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            watchedIconView.widthAnchor.constraint(equalToConstant: 30),
            watchedIconView.heightAnchor.constraint(equalToConstant: 30),
        ])

        progressWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0)
        progressWidthConstraint?.isActive = true
    }
}
