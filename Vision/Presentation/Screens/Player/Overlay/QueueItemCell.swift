import UIKit

final class QueueItemCell: UICollectionViewCell {
    static let reuseID = "QueueItemCell"
    private let posterView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        posterView.translatesAutoresizingMaskIntoConstraints = false
        posterView.contentMode = .scaleAspectFill
        contentView.addSubview(posterView)

        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.cancelPoster()
    }

    func configure(item: VideoQueueItem, style: ThemeStyle, isActive: Bool) {
        posterView.setPoster(url: item.posterURL, placeholder: nil)
        contentView.layer.borderWidth = isActive ? 6 : 0
        contentView.layer.borderColor = style.accent.cgColor
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations {
            if self.isFocused {
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                self.layer.shadowOpacity = 0.4
                self.layer.shadowRadius = 20
                self.layer.shadowOffset = CGSize(width: 0, height: 12)
            } else {
                self.transform = .identity
                self.layer.shadowOpacity = 0
            }
        }
    }
}
