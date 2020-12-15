import UIKit
import Canvas

enum Recognizer {}

class CanvasViewController: UIViewController {
    
    @IBOutlet weak var canvas: Canvas!
    
    private let viewModel = Recognizer.ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.delegate = self
    }
}

extension CanvasViewController: DrawingDelegate {
    func drawingDidStart(on view: DrawingView) {}
    func drawingDidFinish(on view: DrawingView) {
        guard let image = canvas.takeSnapshot() else { return }
        self.viewModel.fetch(image).observe { (result) in
            switch result {
            case .success(let presents):
                print(presents)
            case .failure(_): break
            }
        }
    }
}

