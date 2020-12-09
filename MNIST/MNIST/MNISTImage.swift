import UIKit

public class MNISTImage {
    
    private let image: UIImage
    
    public func mnistImage(image: UIImage) -> UIImage? {

        let mass = image.centerOfMass
        
        let target = CGSize(width: 28, height: 28)
        let scale = max(target.width / mass.width, target.height / mass.height)
        let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let rect = CGRect(origin: CGPoint(x: -mass.minX * scale, y: -mass.minY * scale), size: scaledSize)
        
        UIGraphicsBeginImageContextWithOptions(target, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        
        image.draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public var data: [Float32]? {
        guard let mnistImage = mnistImage(image: image), let data = mnistImage.bytes else { return nil }
        return data.map { 1 - Float32($0) / 255.0 }
    }
    
    public init(_ image: UIImage) {
        self.image = image
    }
}
