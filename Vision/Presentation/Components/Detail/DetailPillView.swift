import UIKit

final class DetailPillView: UIView {
    private let label = UILabel()
    var text: String? { label.text }
    
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        setup(text: text, color: color)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup(text: String, color: UIColor) {
        backgroundColor = color
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        
        label.text = text
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
}
