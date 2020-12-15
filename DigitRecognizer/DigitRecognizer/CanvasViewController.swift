import UIKit
import Canvas
import FutureKit

enum Recognizer {}

protocol Applyable: class {
    func apply(_ presenter: Presenter)
}

class CanvasViewController: UIViewController {
    
    @IBOutlet weak var canvas: Canvas!
    @IBOutlet var interpreter: Interpreter!
    
    private let viewModel = Recognizer.ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.delegate = self
    }
    
    func animateOldTextOffscreen(from: UIView, to: UIImageView, with shotImage: UIImage) {
        guard let snapshot = from.snapshotView(afterScreenUpdates: false) else { return }
        from.addSubview(snapshot)
        let toPoint = to.convert(to.center, to: view)
        let toFrame = to.convert(to.frame, to: view)
        UIView.animateKeyframes(withDuration: 0.55, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                snapshot.center = toPoint
                snapshot.frame = toFrame
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                to.image = shotImage
            }
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

extension CanvasViewController: DrawingDelegate {
    func drawingDidStart(on view: DrawingView) {}
    func drawingDidFinish(on view: DrawingView) {
        canvas.makeSnapshot()
            .convertToPresenter(viewModel)
            .apply(to: interpreter)
    }
}


