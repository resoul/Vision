import UIKit

final class ModalContainerViewController: UIViewController {

    private let content: UIViewController
    private let onDismiss: () -> Void

    init(content: UIViewController, onDismiss: @escaping () -> Void) {
        self.content = content
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(content)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content.view)
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: view.topAnchor),
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        content.didMove(toParent: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Срабатывает и при свайпе, и при Menu на пульте tvOS
        if isBeingDismissed || isMovingFromParent {
            onDismiss()
        }
    }
}
