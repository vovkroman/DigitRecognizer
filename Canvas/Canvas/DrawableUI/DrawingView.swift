import UIKit

open class DrawingView: UIView, Drawable {
    
    var styler: Styler = BlackLineStyler()
    
    private var _drawingLayer: DrawingLayer?
    
    let points: Points = Points(Constant.Points.maxCount)
    
    // MARK: - Initializations
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK: - Private interface
    
    private func setup() {
        points.setDelegate(self)
    }
    
    private func updateFlattenedLayer() {
        guard let drawingLayer = _drawingLayer,
            let newLayer = try? drawingLayer.unarchive(data: drawingLayer.archive()) else { return }
        layer.addSublayer(newLayer)
    }
    
    private func flattenImage() {
        updateFlattenedLayer()
        points.removeAll()
    }
    
    // MARK: - Methods which do custom touch handling
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let new = touches.first?.location(in: self) else { return }
        
        points.add(new)
        
        let last = points.last
        let rect = styler.calculateRectBetween(lastPoint: last, newPoint: new)
        layer.setNeedsDisplay(rect)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenImage()
    }
    
    // MARK: - Methods which responsible for custom drawing
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        guard let path = try? drawBezierPath() else { return }
        let drawingLayer = _drawingLayer ?? DrawingLayer()
        
        drawingLayer.applyStyle(styler)
        drawingLayer.path = path.cgPath
        
        if _drawingLayer == nil {
            _drawingLayer = drawingLayer
            layer.addSublayer(drawingLayer)
        }
    }
}

extension DrawingView: ItemsTracker {
    func didGainMaxCount(_ line: Items) {
        flattenImage()
    }
}

extension DrawingView {
    func applyStyle(_ styler: Styler) {
        styler.applyStyle(to: self)
    }
}
