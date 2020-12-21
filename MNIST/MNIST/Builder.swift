import Accelerate

struct NeuralNetwork {
    let network: [Filter]
    
    func inference(input: [Float32]) -> [Float32] {
        autoreleasepool {
            var outputs = input
            for layer in network {
                let inputs = outputs
                outputs = Array(repeating: 0, count: layer.shape.size)
                
                guard BNNSFilterApply(layer.filter, inputs, &outputs) == 0
                    else { return [] }
            }
            
            return outputs
        }
    }
}

final class Builder {
    
    private var dataType: BNNSDataType {
        get {
            return .float
        }
    }
    
    private var descriptors: ContiguousArray<Descriptor.Layer> = []
    
    private var inputShape: Shape = .default
    private var kernel: Kernel = .default
    private var stride: Stride = .default
    
    private var activation = BNNSActivationFunction.rectifiedLinear
    
    func shape(width: Int, height: Int, channels: Int) -> Self {
        let shape = Shape(width: width, height: height, channels: channels)
        inputShape = shape
        
        if let lastFilter = descriptors.last {
            lastFilter._output = shape
        }
        
        return self
    }
    
    func shape(size: Int) -> Self {
        return shape(width: size, height: 1, channels: 1)
    }
    
    func kernel(width: Int, height: Int) -> Self {
        kernel = .init(width: width, height: height)
        return self
    }
    
    func stride(x: Int, y: Int) -> Self {
        stride = .init(x: x, y: y)
        return self
    }
    
    /// Build method to setup activation function
    /// - Parameter function: BNNS activation function format
    func activation(function: BNNSActivationFunction) -> Self {
        activation = function
        return self
    }
    
    /// Build method to Add ConvolutionLayer, with params and bias
    /// - Parameters:
    ///   - weights: parameter values
    ///   - bias: bias value
    func convolve(weights: [Float32], bias: [Float32]) -> Self {
        let desc = Descriptor.ConvolutionLayer { builder in
            builder.dataType = dataType
            builder.input = inputShape
            builder.kernel = kernel
            builder.stride = stride
            builder.weights = weights
            builder.bias = bias
            builder.activation = activation
        }
        
        descriptors.append(desc)
        return self
    }
    
    func maxpool(width: Int, height: Int) -> Self {
        let desc = Descriptor.MaxPoolingLayer { builder in
            builder.dataType = dataType
            builder.input = inputShape
            builder.kernel = .init(width: width, height: height)
        }
        
        descriptors.append(desc)
        return self
    }
    
    func connect(weights: [Float32], bias: [Float32]) -> Self {
        let desc = Descriptor.FullyConnectedLayer { builder in
            builder.dataType = dataType
            builder.input = inputShape
            builder.weights = weights
            builder.bias = bias
            builder.activation = activation
        }
        
        descriptors.append(desc)
        return self
    }
    
    func build() throws -> NeuralNetwork {
        let network = try descriptors.compactMap { try $0.build() }
        
        guard network.count == descriptors.count else {
            throw NNError.error(description: "Neural netwotk can't be build! Since one of layer is nil")
        }
        
        return NeuralNetwork(network: network)
    }
}
