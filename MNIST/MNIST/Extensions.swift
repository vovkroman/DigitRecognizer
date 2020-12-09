import UIKit

enum NNError: Error {
    case error(description: String)
}

extension Bundle {
    class var current: Bundle {
        return Bundle(identifier: Constants.Bundle.identifier) ?? Bundle.main
    }
}

extension Data {
    
    func toFloat32() throws -> [Float32] {
        var res: [Float32] = Array(repeating: 0, count: count / 4)
        guard copyBytes(to: UnsafeMutableBufferPointer(start: &res, count: res.count)) == count
        else {
            throw NNError.error(description: "Parameters can't be copied")
        }
        return res
    }
}

extension UIImage {
    
    var bytes: Data? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo()

        guard let context = CGContext(data: nil, width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(size.width),
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        context.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        
        let data = Data(bytes: context.data!, count: Int(size.width * size.height))
        
        return data
    }
    
    var centerOfMass: CGRect {
        let width = Int(size.width)
        let height = Int(size.height)
        let midpoint = CGRect(origin: .zero, size: size)
        
        guard let data = bytes else { return midpoint }
        
        var mass: CGFloat = 0
        var rx: CGFloat = 0
        var ry: CGFloat = 0
        var minPoint = CGPoint(x: Int.max, y: Int.max)
        var maxPoint = CGPoint(x: Int.min, y: Int.min)
        
        for row in 0..<height {
            for col in 0..<width {
                let px = 1 - CGFloat(data[row * width + col]) / 255
                guard px > 0 else { continue }
                
                let x = CGFloat(col)
                let y = CGFloat(row)
                
                mass += px
                rx += px * x
                ry += px * y
                
                if x < minPoint.x {
                    minPoint.x = x
                }
                if x > maxPoint.x {
                    maxPoint.x = x
                }
                if y < minPoint.y {
                    minPoint.y = y
                }
                if y > maxPoint.y {
                    maxPoint.y = y
                }
            }
        }
        
        guard mass > 0 else { return midpoint }
        
        let center = CGPoint(x: rx / mass, y: ry / mass)
        
        let hx = max(center.x - minPoint.x, maxPoint.x - center.x)
        let hy = max(center.y - minPoint.y, maxPoint.y - center.y)
        let hh = max(hx, hy)
        
        return CGRect(origin: center, size: CGSize.zero).insetBy(dx: -hh, dy: -hh)
    }
}

extension ContiguousArray where Element == DataLoader {
    subscript(by index: Int) -> [Float32] {
        return self[index].floats
    }
}