import UIKit

class DataLoader {
    
    let floats: [Float32]
    
    init(_ identifier: String) throws {
        guard let asset = NSDataAsset(name: identifier, bundle: .current) else {
            throw NNError.error(description: "Error: There is no asset with such \(identifier) identifier")
        }
        floats = try asset.data.toFloat32()
    }
}

public class MNISTNet {
    
    private let _network: NeuralNetwork
    
    public init?() {
        guard let weights = try? MNISTNet.readWeights(), let nn = try? MNISTNet.setupNetwork(weights) else { return nil }
        _network = nn
    }
    
    private static func readWeights() throws -> ContiguousArray<DataLoader> {
        let h1_h2_weights = try DataLoader("model-h1w-5x5x1x32")
        let h1_h2_bias = try DataLoader("model-h1b-32")
        let h2_h3_weights = try DataLoader("model-h2w-5x5x32x64")
        let h2_h3_bias = try DataLoader("model-h2b-64")
        let h3_h4_weights = try DataLoader("model-h3w-3136x1024")
        let h3_h4_bias = try DataLoader("model-h3b-1024")
        let h4_y_weights = try DataLoader("model-h4w-1024x10")
        let h4_y_bias = try DataLoader("model-h4b-10")
        
        return ContiguousArray([h1_h2_weights, h1_h2_bias,
                                h2_h3_weights, h2_h3_bias,
                                h3_h4_weights, h3_h4_bias,
                                h4_y_weights, h4_y_bias])
    }
    
    private static func setupNetwork(_ weights: ContiguousArray<DataLoader>) throws -> NeuralNetwork? {
        return try NNBuilder()
            .shape(width: 28, height: 28, channels: 1)
            .kernel(width: 5, height: 5)
            .convolve(weights: weights[by: 0], bias: weights[by: 1])
            .shape(width: 28, height: 28, channels: 32)
            .maxpool(width: 2, height: 2)
            .shape(width: 14, height: 14, channels: 32)
            .convolve(weights: weights[by: 2], bias: weights[by: 3])
            .shape(width: 14, height: 14, channels: 64)
            .maxpool(width: 2, height: 2)
            .shape(width: 7, height: 7, channels: 64)
            .connect(weights: weights[by: 4], bias: weights[by: 5])
            .shape(size: 1024)
            .connect(weights: weights[by: 6], bias: weights[by: 7])
            .shape(size: 10)
            .build()
    }
    
    public func predict(image: Data) -> Int {
        return predict(input: read(image: image))
    }
    
    public func predict(input: [Float32]) -> Int {
        
        let outputs = _network.apply(input: input)
        
        return outputs.firstIndex(of: outputs.max()!)!
    }
    
    private func read(image: Data) -> [Float32] {
        return image.map { Float32($0) / 255.0 }
    }
}
