import UIKit
import FutureKit

extension Array where Element: Comparable {

    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

extension UIImage {
    static func makeOptimizedImage(from image: UIImage) -> UIImage {
        let imageSize: CGSize = image.size
        UIGraphicsBeginImageContextWithOptions(imageSize, true, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return optimizedImage ?? UIImage()
    }
//    static func makeOptimizedImage(from image: UIImage) -> UIImage {
//        let config = UIGraphicsImageRendererFormat()
//        config.opaque = true
//        let render = UIGraphicsImageRenderer(size: image.size, format: config)
//        let imageSize: CGSize = image.size
//        return  render.image { ctx in
//            UIColor.white.set()
//            let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
//            ctx.fill(rect)
//            image.draw(in: rect, blendMode: .multiply, alpha: 0.5)
//        }
//    }
}

protocol Transparentable {
    func transparentBar()
}

extension Transparentable where Self : UINavigationController {
    
    func transparentBar() {
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}

extension Future where Value == [Float] {
    
    func makePresenter() throws -> Future<Recognizer.Node> {
        transformed { values in
            try .init(values)
        }
    }
}

extension Future where Value == UIImage {    
    func convertOf(_ viewModel: Recognizer.ViewModel) throws -> Future<Recognizer.Node> {
        chained { value in
            return try viewModel.fetch(value)
        }
    }
    
    func animate<T: Animatable>(view: T) -> Future<Value> {
        chained { [unowned self] value in
            let optimizedImage = UIImage.makeOptimizedImage(from: value)
            DispatchQueue.main.async {
                view.performSnapshot(optimizedImage)
            }
            return self
        }
    }
}

extension Future where Value == Recognizer.Node {
    @discardableResult
    func apply<Type: Applyable>(to view: Type) -> Future<Void>{
        chained { value in
            let promise = Promise<Void>()
            DispatchQueue.main.async {
                view.apply(value)
                promise.resolve(with: ())
            }
            return promise
        }
    }
}
