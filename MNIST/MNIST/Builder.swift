import Accelerate

struct NeuralNetwork {
    let network: [Filter]
    
    func inference(input: [Float32]) -> [Float32] {
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

class Builder {
    
    var dataType: BNNSDataType {
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
            lastFilter.output = shape
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
    
    func activation(function: BNNSActivationFunction) -> Self {
        activation = function
        return self
    }
    
    func convolve(weights: [Float32], bias: [Float32]) -> Self {
        let desc = Descriptor.ConvolutionLayer()
        desc.dataType = dataType
        desc.input = inputShape
        desc.kernel = kernel
        desc.stride = stride
        desc.weights = weights
        desc.bias = bias
        desc.activation = activation
        
        descriptors.append(desc)
        return self
    }
    
    func maxpool(width: Int, height: Int) -> Self {
        let desc = Descriptor.MaxPoolingLayer()
        desc.dataType = dataType
        desc.input = inputShape
        desc.kernel = .init(width: width, height: height)
        
        descriptors.append(desc)
        return self
    }
    
    func connect(weights: [Float32], bias: [Float32]) -> Self {
        let desc = Descriptor.FullyConnectedLayer()
        desc.dataType = dataType
        desc.input = inputShape
        desc.weights = weights
        desc.bias = bias
        desc.activation = activation
        
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
