import UIKit

final class VideoPreviewPresenter {

    // MARK: - Configuration

    struct Config {
        var horizontalPadding: CGFloat = 15
        var bottomPadding: CGFloat = 15
        var cellSize:      CGSize  = .zero

        var panelWidth:  CGFloat { cellSize.width * 2.5 + 28 }
        var panelHeight: CGFloat { cellSize.height * 0.6 }
    }

    // MARK: - Private state

    private let overlayView    = VideoPreviewView()
    private var config         = Config()
    private var currentMovieId: Int?
    private var currentStyle: ThemeStyle?

    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Public API

    func updateStyle(_ style: ThemeStyle) {
        self.currentStyle = style
    }

    func attach(to view: UIView) {
        guard overlayView.superview == nil else { return }
        
        view.addSubview(overlayView)
        overlayView.layer.zPosition = 100
        overlayView.isHidden = true
        overlayView.isUserInteractionEnabled = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // Use frameLayoutGuide if it's a scroll view to keep it fixed.
        // For regular views, pin to raw bounds (ignore safe area insets).
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        if let scrollView = view as? UIScrollView {
            leadingAnchor = scrollView.frameLayoutGuide.leadingAnchor
            trailingAnchor = scrollView.frameLayoutGuide.trailingAnchor
            bottomAnchor = scrollView.frameLayoutGuide.bottomAnchor
        } else {
            leadingAnchor = view.leadingAnchor
            trailingAnchor = view.trailingAnchor
            bottomAnchor = view.bottomAnchor
        }

        let trailing = overlayView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -config.horizontalPadding)
        let leading = overlayView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: config.horizontalPadding)
        let bottom = overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -config.bottomPadding)
        let width = overlayView.widthAnchor.constraint(equalToConstant: config.panelWidth)
        let height = overlayView.heightAnchor.constraint(equalToConstant: config.panelHeight)
        
        NSLayoutConstraint.activate([leading, trailing, bottom, width, height])
        
        self.trailingConstraint = trailing
        self.leadingConstraint = leading
        self.bottomConstraint = bottom
        self.widthConstraint = width
        self.heightConstraint = height
    }

    func show(for movie: ContentItem, cellSize: CGSize) {
        guard movie.id != currentMovieId else { return }
        currentMovieId  = movie.id
        config.cellSize = cellSize

        if let style = currentStyle {
            overlayView.configure(with: VideoPreviewViewModel(movie: movie), style: style)
        }
        updateLayout()
        overlayView.isHidden = false
    }

    func hide() {
        currentMovieId = nil
        overlayView.isHidden = true
    }
    
    func updateLayout() {
        widthConstraint?.constant = config.panelWidth
        heightConstraint?.constant = config.panelHeight
        trailingConstraint?.constant = -config.horizontalPadding
        leadingConstraint?.constant = config.horizontalPadding
        bottomConstraint?.constant = -config.bottomPadding
    }
}
