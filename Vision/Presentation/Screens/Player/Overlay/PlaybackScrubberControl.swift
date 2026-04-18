import UIKit

final class PlaybackScrubberControl: UIControl {
    var minimumTrackTintColor: UIColor = .white {
        didSet { fillView.backgroundColor = minimumTrackTintColor }
    }
    var maximumTrackTintColor: UIColor = .white.withAlphaComponent(0.3) {
        didSet { trackView.backgroundColor = maximumTrackTintColor }
    }
    var thumbTintColor: UIColor = .white {
        didSet { thumbView.backgroundColor = thumbTintColor }
    }
    var value: CGFloat = 0 {
        didSet {
            value = min(max(value, 0), 1)
            updateLayout()
        }
    }

    private let trackView = UIView()
    private let fillView = UIView()
    private let thumbView = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?
    private var thumbCenterConstraint: NSLayoutConstraint?

    override var canBecomeFocused: Bool { true }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 40).isActive = true

        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.layer.cornerRadius = 3
        addSubview(trackView)

        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 3
        trackView.addSubview(fillView)

        thumbView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.layer.cornerRadius = 10
        thumbView.alpha = 0
        addSubview(thumbView)

        NSLayoutConstraint.activate([
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.heightAnchor.constraint(equalToConstant: 6),

            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),

            thumbView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 20),
            thumbView.heightAnchor.constraint(equalToConstant: 20)
        ])

        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true

        thumbCenterConstraint = thumbView.centerXAnchor.constraint(equalTo: leadingAnchor)
        thumbCenterConstraint?.isActive = true

        // Ensure scrubber is visible even before first style update.
        trackView.backgroundColor = maximumTrackTintColor
        fillView.backgroundColor = minimumTrackTintColor
        thumbView.backgroundColor = thumbTintColor
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let delta: CGFloat = 0.05
        if presses.contains(where: { $0.type == .leftArrow }) {
            value -= delta
            sendActions(for: .valueChanged)
        } else if presses.contains(where: { $0.type == .rightArrow }) {
            value += delta
            sendActions(for: .valueChanged)
        } else {
            super.pressesEnded(presses, with: event)
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations {
            let focused = self.isFocused
            self.thumbView.alpha = focused ? 1 : 0
            self.trackView.transform = focused ? CGAffineTransform(scaleX: 1.0, y: 1.5) : .identity
        }
    }

    private func updateLayout() {
        guard bounds.width > 0 else { return }
        let fillWidth = bounds.width * value
        fillWidthConstraint?.constant = fillWidth
        thumbCenterConstraint?.constant = min(max(fillWidth, 10), bounds.width - 10)
        layoutIfNeeded()
    }
}
