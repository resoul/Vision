import UIKit

final class DetailButton: TVFocusControl {
    enum Style {
        case primary
        case secondary
    }
    
    private let label = UILabel()
    private let iconIV = UIImageView()
    private let style: Style
    
    var onPrimaryAction: (() -> Void)?
    
    init(title: String, icon: UIImage? = nil, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        setup(title: title, icon: icon)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup(title: String, icon: UIImage?) {
        focusScale = 1.05
        
        label.text = title
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        iconIV.image = icon
        iconIV.contentMode = .scaleAspectFit
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [iconIV, label])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            iconIV.widthAnchor.constraint(equalToConstant: 28),
            iconIV.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        iconIV.isHidden = icon == nil
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        onPrimaryAction?()
    }
    
    func setTitle(_ title: String) {
        label.text = title
    }
    
    func setIcon(_ icon: UIImage?) {
        iconIV.image = icon
        iconIV.isHidden = icon == nil
    }
    
    func setThemeStyle(_ theme: ThemeStyle) {
        switch style {
        case .primary:
            bgView.backgroundColor = theme.accent
            label.textColor = .white
            iconIV.tintColor = .white
        case .secondary:
            bgView.backgroundColor = theme.surface.withAlphaComponent(0.8)
            label.textColor = theme.textPrimary
            iconIV.tintColor = theme.textPrimary
        }
    }
    
    override func applyFocusAppearance(focused: Bool) {
        bgView.layer.borderColor = focused ? UIColor.white.cgColor : UIColor.clear.cgColor
        bgView.layer.borderWidth = focused ? 4 : 0
        
        if style == .secondary {
            bgView.alpha = focused ? 1.0 : 0.8
        }
    }
}
