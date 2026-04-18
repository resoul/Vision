import UIKit

final class TranslationRow: TVFocusControl {
    private let studioLabel = UILabel()
    private let qualityLabel = UILabel()
    private let playIcon = UIImageView(image: UIImage(systemName: "play.fill"))
    
    var onPlay: (() -> Void)?
    
    init(studio: String, quality: String) {
        super.init(frame: .zero)
        setup(studio: studio, quality: quality)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup(studio: String, quality: String) {
        focusScale = 1.02
        normalBgAlpha = 0.05
        
        studioLabel.text = studio
        studioLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        studioLabel.textColor = .white
        
        qualityLabel.text = quality
        qualityLabel.font = .systemFont(ofSize: 20, weight: .bold)
        qualityLabel.textColor = .systemGreen
        
        playIcon.tintColor = .white
        playIcon.contentMode = .scaleAspectFit
        
        let stack = UIStackView(arrangedSubviews: [playIcon, studioLabel, UIView(), qualityLabel])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            playIcon.widthAnchor.constraint(equalToConstant: 24),
            playIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        onPlay?()
    }
    
    func setThemeStyle(_ style: ThemeStyle) {
        studioLabel.textColor = style.textPrimary
        qualityLabel.textColor = style.accent
        playIcon.tintColor = style.textPrimary
        bgView.backgroundColor = style.textPrimary.withAlphaComponent(0.1)
    }
}
