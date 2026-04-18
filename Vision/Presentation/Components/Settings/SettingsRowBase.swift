import UIKit

class SettingsRowBase: TVFocusControl {
    let bgLayer = UIView()
    var currentStyle: ThemeStyle?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBase()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBase() {
        focusScale = 1.02
        normalBgAlpha = 0.0
        
        bgLayer.layer.cornerRadius = 14
        bgLayer.layer.cornerCurve = .continuous
        bgLayer.translatesAutoresizingMaskIntoConstraints = false
        bgLayer.isUserInteractionEnabled = false
        addSubview(bgLayer)
        sendSubviewToBack(bgLayer)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 76),
            bgLayer.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            bgLayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgLayer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgLayer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
    }
    
    func updateColors(style: ThemeStyle) {
        self.currentStyle = style
        updateAppearance()
    }
    
    override func applyFocusAppearance(focused: Bool) {
        updateAppearance()
    }
    
    private func updateAppearance() {
        guard let style = currentStyle else { return }
        
        // Old project style: 0.12 alpha for focus, 0.20 for press
        // We use isPressed from TVFocusControl if available, or just focus
        let alpha: CGFloat = isFocused ? 0.12 : 0.0
        bgLayer.backgroundColor = style.textPrimary.withAlphaComponent(alpha)
        
        // If we want to support press state visual feedback:
        // (Note: TVFocusControl might need a small update to expose press state easily, 
        // but we can also use touchesBegan/Ended if needed)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let style = currentStyle else { return }
        UIView.animate(withDuration: 0.1) {
            self.bgLayer.backgroundColor = style.textPrimary.withAlphaComponent(0.20)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateAppearance()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updateAppearance()
    }
}
