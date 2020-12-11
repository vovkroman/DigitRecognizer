import UIKit

struct Weights {
    let weights: [Float32]
    let bias: [Float]
    
    init(_ weights_loader: DataLoader, bias_loader: DataLoader) {
        self.weights = weights_loader.floats
        self.bias = bias_loader.floats
    }
}

struct DataLoader {
    
    let floats: [Float32]
    
    init(_ identifier: String) throws {
        guard let asset = NSDataAsset(name: identifier, bundle: .current) else {
            throw NNError.error(description: "Error: There is no asset with such \(identifier) identifier")
        }
        floats = try asset.data.toFloat32()
    }
}
