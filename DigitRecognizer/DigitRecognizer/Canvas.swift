import Canvas
import UIKit

protocol Borderable: class {
    //func setupBorder()
}

extension Canvas: Borderable {
//    func setupBorder() {
//        // Add rounded corners
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = bounds
//        let bezierPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
//        maskLayer.path = bezierPath.cgPath
//        layer.mask = maskLayer
//
//        // Add border
//        let borderLayer = CAShapeLayer()
//        borderLayer.path = maskLayer.path // Reuse the Bezier path
//        borderLayer.fillColor = UIColor.clear.cgColor
//        borderLayer.strokeColor = UIColor.orange.cgColor
//        borderLayer.lineWidth = 2
//        borderLayer.frame = bounds
//        layer.addSublayer(borderLayer)
//    }
}

class Canvas: DrawingView {

    func getImageRepresentation() -> UIImage? {
        let imageBounds = bounds.offsetBy(dx: 2, dy: 2)
        UIGraphicsBeginImageContextWithOptions(imageBounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.setupBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //self.setupBorder()
    }
}
