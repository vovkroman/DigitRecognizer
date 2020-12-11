import UIKit
import Canvas
import MNIST

class Canvas: DrawingView {
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class ViewController: UIViewController {
    let ai = MNIST()
    
    @IBOutlet weak var canvas: Canvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func recognize(_ sender: Any) {
        guard let image = canvas.getImage(), let data = MNISTImage(image).data else { return }
        print(image)
        print(ai?.predict(input: data))
    }
}

