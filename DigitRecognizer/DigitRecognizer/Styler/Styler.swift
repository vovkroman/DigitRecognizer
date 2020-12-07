import UIKit

protocol Calculable {
    // Needs to be implemented in styler since result is depands on specific style
    func calculateRectBetween(lastPoint: CGPoint, newPoint: CGPoint) -> CGRect
}

protocol Styler: Calculable {
    func applyStyle(to layer: DrawingLayer)
    func applyStyle(to view: DrawingView)
}

struct BlackLineStyler: Styler {
    
    struct BlackLine {
        let width: CGFloat
        let color: UIColor
        let opacity: Float
        init() {
            let lineType = Constant.Line.self
            
            self.width = lineType.width
            self.color = lineType.color
            self.opacity = lineType.opacity
        }
    }
    
    private let line: BlackLine = BlackLine()
    
    func applyStyle(to layer: DrawingLayer) {
        layer.contentsScale = Constant.Display.scale
        layer.opacity = line.opacity
        layer.lineWidth = line.width
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = line.color.cgColor
    }
    
    func applyStyle(to view: DrawingView) {
        // Nothing to do
    }
    
    func calculateRectBetween(lastPoint: CGPoint, newPoint: CGPoint) -> CGRect {
        let originX = min(lastPoint.x, newPoint.x) - (line.width / 2)
        let originY = min(lastPoint.y, newPoint.y) - (line.width / 2)
        
        let maxX = max(lastPoint.x, newPoint.x) + (line.width / 2)
        let maxY = max(lastPoint.y, newPoint.y) + (line.width / 2)
        
        let width = maxX - originX
        let height = maxY - originY
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
