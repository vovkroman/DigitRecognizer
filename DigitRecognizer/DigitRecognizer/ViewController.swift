import UIKit
import Canvas
import MNIST

class ViewController: UIViewController {
    let ai = MNIST()
    
    @IBOutlet weak var canvas: Canvas!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension ViewController: DrawingDelegate {
    func drawingDidStart(on view: DrawingView) {}
    func drawingDidFinish(on view: DrawingView) {
        guard let image = canvas.getImageRepresentation() else { return }
        let imageView = UIImageView(frame: image.)
    }
}

