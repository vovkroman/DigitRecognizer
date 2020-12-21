import UIKit

public protocol DrawingDelegate: class {
    func drawingDidStart(on view: DrawingView)
    func drawingDidFinish(on view: DrawingView)
}

open class DrawingView: UIView, Drawable {
    
    var styler: Styler = BlackLineStyler()
    
    private var _drawingLayer: DrawingLayer?
    private var _sublayers: [CALayer] {
        return layer.sublayers ?? []
    }
    
    public weak var delegate: DrawingDelegate?
    
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
    
    private func tryToFinishDrawing() {
        weak var weakSelf = self
        guard let _weak = weakSelf else { return }
        NSObject.cancelPreviousPerformRequests(withTarget: _weak, selector: #selector(finishedDrawing), object: nil)
        _weak.perform(#selector(finishedDrawing), with: nil, afterDelay: 1.5)
    }
    
    private func cancelPreviousDrawing() {
        weak var weakSelf = self
        guard let _weak = weakSelf else { return }
        NSObject.cancelPreviousPerformRequests(withTarget: _weak, selector: #selector(finishedDrawing), object: nil)
    }
    
    @objc private func finishedDrawing() {
        delegate?.drawingDidFinish(on: self)
    }
    
    // MARK: - Methods which do custom touch handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        cancelPreviousDrawing()
        delegate?.drawingDidStart(on: self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let new = touches.first?.location(in: self) else { return }
        
        points.add(new)
        
        let last = points.last
        let rect = styler.calculateRectBetween(lastPoint: last, newPoint: new)
        layer.setNeedsDisplay(rect)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenImage()
        tryToFinishDrawing()
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
    
    // MARK: - Cleaning
    
    private func emptyFlattenedLayers() {
        for case let layer as CAShapeLayer in _sublayers {
            layer.removeFromSuperlayer()
        }
    }
    
    public func clear() {
        emptyFlattenedLayers()
        _drawingLayer?.removeFromSuperlayer()
        _drawingLayer = nil
        points.removeAll()
        layer.setNeedsDisplay()
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
