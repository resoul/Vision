import UIKit

final class GenreButton: TVFocusControl {
    var isActiveTab: Bool = false {
        didSet { updateLook(animated: true) }
    }

    private let config: TabBarConfiguration
    private let label = UILabel()

    init(genre: GenreItem, config: TabBarConfiguration) {
        self.config = config
        super.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = genre.title
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -14),
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10),
        ])
        updateLook(animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyFocusAppearance(focused: Bool) {
        label.textColor = focused ? config.activeColor : (isActiveTab ? config.activeColor : config.inactiveColor)
        
        let bgAlpha = focused ? config.focusedBgAlpha : (isActiveTab ? 0.08 : 0)
        let bgColor = focused ? config.activeColor : (isActiveTab ? config.activeColor : .clear)
        bgView.backgroundColor = bgColor.withAlphaComponent(bgAlpha)
    }

    private func updateLook(animated: Bool) {
        let block = {
            self.label.textColor = self.isActiveTab ? self.config.activeColor : self.config.inactiveColor
            self.bgView.backgroundColor = self.config.activeColor.withAlphaComponent(self.isActiveTab ? 0.08 : 0)
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: block)
        } else {
            block()
        }
    }
}
