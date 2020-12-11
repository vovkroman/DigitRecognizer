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

private func readWeights() throws -> [Weights] {
    return [Weights(try DataLoader("model-h1w-5x5x1x32"), bias_loader: try DataLoader("model-h1b-32")),
            Weights(try DataLoader("model-h2w-5x5x32x64"), bias_loader: try DataLoader("model-h2b-64")),
            Weights(try DataLoader("model-h3w-3136x1024"), bias_loader: try DataLoader("model-h3b-1024")),
            Weights(try DataLoader("model-h4w-1024x10"), bias_loader: try DataLoader("model-h4b-10"))]
}

public class MNIST {
    private let _network: NeuralNetwork
    
    public init?() {
        guard let weights = try? readWeights(), let nn = try? MNIST.setupNetwork(weights) else { return nil }
        _network = nn
    }
    
    private static func setupNetwork(_ weights: [Weights]) throws -> NeuralNetwork {
        return try Builder()
            .shape(width: 28, height: 28, channels: 1)
            .kernel(width: 5, height: 5)
            .convolve(weights: weights[0].weights, bias: weights[0].bias)
            .shape(width: 28, height: 28, channels: 32)
            .maxpool(width: 2, height: 2)
            .shape(width: 14, height: 14, channels: 32)
            .convolve(weights: weights[1].weights, bias: weights[1].bias)
            .shape(width: 14, height: 14, channels: 64)
            .maxpool(width: 2, height: 2)
            .shape(width: 7, height: 7, channels: 64)
            .connect(weights: weights[2].weights, bias: weights[2].bias)
            .shape(size: 1024)
            .connect(weights: weights[3].weights, bias: weights[3].bias)
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
