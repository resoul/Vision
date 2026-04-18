import UIKit

final class RatingBadgeView: UIView {
    private let logoLabel = UILabel()
    private let ratingLabel = UILabel()
    private let votesLabel = UILabel()
    
    init(logo: String, logoColor: UIColor, rating: String, votes: String) {
        super.init(frame: .zero)
        setup(logo: logo, logoColor: logoColor, rating: rating, votes: votes)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup(logo: String, logoColor: UIColor, rating: String, votes: String) {
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        
        logoLabel.text = logo
        logoLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        logoLabel.textColor = logoColor
        
        ratingLabel.text = rating
        ratingLabel.font = .systemFont(ofSize: 24, weight: .bold)
        ratingLabel.textColor = .white
        
        votesLabel.text = votes
        votesLabel.font = .systemFont(ofSize: 16, weight: .regular)
        votesLabel.textColor = UIColor(white: 1, alpha: 0.5)
        
        let stack = UIStackView(arrangedSubviews: [logoLabel, ratingLabel, votesLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
}
