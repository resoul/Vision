import UIKit

final class SearchButton: TVFocusControl {
    private let config: TabBarConfiguration
    private let iconView = UIImageView()
    private let label = UILabel()

    init(config: TabBarConfiguration, searchTitle: String) {
        self.config = config
        super.init(frame: .zero)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "magnifyingglass")
        label.text = searchTitle
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        addSubview(iconView)
        addSubview(label)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -18),
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
        ])
        applyFocusAppearance(focused: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyFocusAppearance(focused: Bool) {
        label.textColor = focused ? config.activeColor : config.inactiveColor
        iconView.tintColor = focused ? config.activeColor : config.inactiveColor
    }
}
