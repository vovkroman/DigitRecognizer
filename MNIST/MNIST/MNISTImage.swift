import UIKit

public class MNISTImage {
    public let image: UIImage
    
    var mnistData: [Float32] {
        guard let data = image.bytes else { return [] }
        return data.map { 1 - Float32($0) / 255.0 }
    }
    
    public init(_ image: UIImage) throws {
        guard let mnist = image.MNIST else {
            throw NNError.error(description: "Image can't be transformed to MNIST format")
        }
        self.image = mnist
    }
}
