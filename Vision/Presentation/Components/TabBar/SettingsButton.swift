import UIKit

final class SettingsButton: TVFocusControl {
    var canFocusAfterDismiss: Bool = true
    override var canBecomeFocused: Bool { canFocusAfterDismiss }
    private let config: TabBarConfiguration
    private let iconView = UIImageView()

    init(config: TabBarConfiguration) {
        self.config = config
        super.init(frame: .zero)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "gearshape.fill")
        addSubview(iconView)
        NSLayoutConstraint.activate([
            bgView.widthAnchor.constraint(equalToConstant: 52),
            bgView.heightAnchor.constraint(equalToConstant: 48),
            iconView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])
        applyFocusAppearance(focused: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyFocusAppearance(focused: Bool) {
        iconView.tintColor = focused ? config.activeColor : config.inactiveColor
    }
}
