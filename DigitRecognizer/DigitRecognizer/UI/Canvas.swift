import Canvas
import UIKit
import FutureKit

class Canvas: DrawingView {
    
    private typealias ViewSnapshot = (layer: CALayer, bounds: CGRect)
    
    private let _worker = DispatchQueue.global(qos: .userInteractive)
    
    func makeSnapshot() -> Future<UIImage> {
        let view = ViewSnapshot(layer: layer, bounds: bounds)
        let promise = Promise<UIImage>()
        _worker.async {
            let image = self.makeSnapshot(of: view.layer, bounds: view.bounds)
            promise.resolve(with: image)
        }
        return promise
    }
    
    private func makeSnapshot(of layer: CALayer, bounds: CGRect) -> UIImage {
        let config = UIGraphicsImageRendererFormat()
        config.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: config)
        let image = renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
