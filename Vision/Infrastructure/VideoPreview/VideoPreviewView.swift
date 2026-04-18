import UIKit

final class VideoPreviewView: UIView {

    // MARK: - Subviews

    private let blurView = UIVisualEffectView()
    private let accentLine = UIView()
    private let titleLabel = UILabel()
    private let pillsStack = UIStackView()
    private let descLabel = UILabel()
    private let lastAddedLabel = UILabel()
    
    private let contentStack = UIStackView()
    private let mainRowStack = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = false
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 12)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        addSubview(blurView)

        accentLine.translatesAutoresizingMaskIntoConstraints = false
        accentLine.layer.cornerRadius = 2
        accentLine.layer.cornerCurve = .continuous

        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail

        pillsStack.axis = .horizontal
        pillsStack.spacing = 6
        pillsStack.alignment = .center

        descLabel.numberOfLines = 5
        descLabel.lineBreakMode = .byTruncatingTail

        lastAddedLabel.numberOfLines = 1

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.alignment = .fill

        let infoStack = UIStackView(arrangedSubviews: [descLabel, lastAddedLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .fill

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(pillsStack)
        contentStack.addArrangedSubview(infoStack)

        mainRowStack.translatesAutoresizingMaskIntoConstraints = false
        mainRowStack.axis = .horizontal
        mainRowStack.spacing = 18
        mainRowStack.alignment = .top // Align to top because title is the anchor
        
        mainRowStack.addArrangedSubview(accentLine)
        mainRowStack.addArrangedSubview(contentStack)

        blurView.contentView.addSubview(mainRowStack)

        let topConstraint = mainRowStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 22)
        let leadingConstraint = mainRowStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20)
        let trailingConstraint = mainRowStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20)
        let bottomConstraint = mainRowStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -22)
        
        [topConstraint, leadingConstraint, trailingConstraint, bottomConstraint].forEach { $0.priority = .init(999) }
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            accentLine.widthAnchor.constraint(equalToConstant: 4),
            accentLine.heightAnchor.constraint(equalTo: contentStack.heightAnchor),
            
            topConstraint, leadingConstraint, trailingConstraint, bottomConstraint
        ])
    }

    // MARK: - Configuration

    func configure(with viewModel: VideoPreviewViewModel, style: ThemeStyle) {
        blurView.effect = UIBlurEffect(style: style.background.isDark ? .dark : .light)
        blurView.contentView.backgroundColor = style.background.withAlphaComponent(0.88)
        
        accentLine.backgroundColor = viewModel.accentColor.lighter(by: 0.55)
        
        titleLabel.attributedText = NSAttributedString(
            string: viewModel.title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 34, weight: .heavy),
                .foregroundColor: style.textPrimary
            ]
        )

        // Clear previous pills
        pillsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let ratingPill = PillView(
            text: viewModel.rating,
            color: UIColor(red: 1, green: 0.82, blue: 0, alpha: 1)
        )
        pillsStack.addArrangedSubview(ratingPill)

        if !viewModel.year.isEmpty && viewModel.year != "—" {
            let yearPill = PillView(
                text: viewModel.year,
                color: style.textSecondary.withAlphaComponent(0.25)
            )
            pillsStack.addArrangedSubview(yearPill)
        }

        for genre in viewModel.genres.prefix(2) where !genre.isEmpty && genre != "—" {
            let genrePill = PillView(
                text: genre,
                color: viewModel.accentColor.withAlphaComponent(0.80)
            )
            pillsStack.addArrangedSubview(genrePill)
        }

        if viewModel.description.isEmpty {
            descLabel.isHidden = true
            descLabel.text = nil
        } else {
            descLabel.isHidden = false
            descLabel.attributedText = NSAttributedString(
                string: viewModel.description,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 22, weight: .regular),
                    .foregroundColor: style.textSecondary
                ]
            )
        }

        if let last = viewModel.lastAdded, !last.isEmpty {
            lastAddedLabel.isHidden = false
            lastAddedLabel.attributedText = NSAttributedString(
                string: "▸ \(last)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                    .foregroundColor: style.accent
                ]
            )
        } else {
            lastAddedLabel.isHidden = true
            lastAddedLabel.text = nil
        }
    }
}
