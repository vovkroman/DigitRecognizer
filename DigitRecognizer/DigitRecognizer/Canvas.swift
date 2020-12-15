import Canvas
import UIKit
import FutureKit

class Canvas: DrawingView {
    
    private let worker = DispatchQueue.global(qos: .userInteractive)
    
    typealias ViewSnapshot = (layer: CALayer, bounds: CGRect)
    
    func makeSnapshot() -> Future<UIImage> {
        let view = ViewSnapshot(layer: layer, bounds: bounds)
        let promise = Promise<UIImage>()
        worker.async {
            let image = self.makeSnapshot(of: view.layer, bounds: view.bounds)
            promise.resolve(with: image)
        }
        return promise
    }
    
    func makeSnapshot(of layer: CALayer, bounds: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
