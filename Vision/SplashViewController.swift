import UIKit

class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo"))
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private var particleEmitter: CAEmitterLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLogo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startParticles()
        animateLogo()
    }

    private func setupLogo() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
        ])
    }

    private func startParticles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitter.emitterShape  = .sphere
        emitter.emitterSize   = CGSize(width: view.bounds.width * 0.6,
                                       height: view.bounds.height * 0.6)
        emitter.renderMode    = .additive

        emitter.emitterCells = [makeStarCell(color: .white,   birthRate: 60),
                                makeStarCell(color: .cyan,    birthRate: 30),
                                makeStarCell(color: .yellow,  birthRate: 20)]

        view.layer.insertSublayer(emitter, at: 0)
        particleEmitter = emitter

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.birthRate = 0
        }
    }

    private func makeStarCell(color: UIColor, birthRate: Float) -> CAEmitterCell {
        let cell = CAEmitterCell()
        let size: CGFloat = 4
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        cell.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()

        cell.birthRate      = birthRate
        cell.lifetime       = 2.5
        cell.lifetimeRange  = 1.0
        cell.velocity       = 80
        cell.velocityRange  = 50
        cell.emissionRange  = .pi * 2
        cell.scale          = 0.5
        cell.scaleRange     = 0.4
        cell.scaleSpeed     = -0.1
        cell.alphaSpeed     = -0.4
        cell.spin           = 0.3
        cell.spinRange      = 0.8

        return cell
    }

    private func animateLogo() {
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(
            withDuration: 1.0,
            delay: 0.2,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.3,
            options: [],
            animations: {
                self.logoImageView.alpha = 1
                self.logoImageView.transform = .identity
            }
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.transitionToMain()
        }
    }

    private func transitionToMain() {
        UIView.animate(withDuration: 0.6, animations: {
            self.view.alpha = 0
        }) { _ in
            self.onFinish?()
        }
    }
}
