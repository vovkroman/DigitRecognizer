import UIKit

enum DrawingExeption: Error {
    case error(reason: String)
}

protocol Archivable: class {
    func unarchive(data: Data) throws -> Self?
    func archive(is secureCoding: Bool) throws -> Data
}

protocol Drawable: class {
    var points: Points { get }
    func drawBezierPath() throws -> UIBezierPath
}

extension Drawable where Self: DrawingView {
    
    func drawBezierPath() throws -> UIBezierPath {
        guard let first = points.first else {
            throw DrawingExeption.error(reason: "Can't be draw since, empty line!")
        }
        let linePath = UIBezierPath()
        linePath.move(to: first)
        
        for index in 1..<points.count {
            linePath.addLine(to: points[index])
        }
        return linePath
    }
}

extension StyleManager {
    static func appearance<T: UIView>(aClass: T.Type) -> StyleManager {
        return __shared(aClass)
    }
    
    static func invoke<T: UIView>(for target: T) {
        __invokeMethods(target)
    }
}
