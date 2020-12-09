import Accelerate

struct NNShape {
    let width: Int
    let height: Int
    let channels: Int
    
    var size: Int {
        get {
            return width * height * channels
        }
    }
}


class NNFilter {
    let filter: BNNSFilter
    let shape: NNShape
    
    init(filter: BNNSFilter, shape: NNShape) {
        self.filter = filter
        self.shape = shape
    }
    
    deinit { BNNSFilterDestroy(filter) }
}


struct NeuralNetwork {
    let network: [NNFilter]
    
    func apply(input: [Float32]) -> [Float32] {
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

class NNBuilder {
    
    var dataType: BNNSDataType {
        get {
            return BNNSDataType.float
        }
    }
    
    private var descriptors: [LayerDescriptor] = []
    
    private var inputShape: NNShape!
    private var kernel: (width: Int, height: Int)!
    private var stride = (x: 1, y: 1)
    private var activation = BNNSActivationFunction.rectifiedLinear
    
    func shape(width: Int, height: Int, channels: Int) -> Self {
        let shape = NNShape(width: width, height: height, channels: channels)
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
        kernel = (width: width, height: height)
        return self
    }
    
    func stride(x: Int, y: Int) -> Self {
        stride = (x: x, y: y)
        return self
    }
    
    func activation(function: BNNSActivationFunction) -> Self {
        activation = function
        return self
    }
    
    func convolve(weights: [Float32], bias: [Float32]) -> Self {
        let desc = ConvolutionLayerDescriptor()
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
        let desc = MaxPoolingLayerDescriptor()
        desc.dataType = dataType
        desc.input = inputShape
        desc.kernel = (width: width, height: height)
        
        descriptors.append(desc)
        return self
    }
    
    func connect(weights: [Float32], bias: [Float32]) -> Self {
        let desc = FullyConnectedLayerDescriptor()
        desc.dataType = dataType
        desc.input = inputShape
        desc.weights = weights
        desc.bias = bias
        desc.activation = activation
        
        descriptors.append(desc)
        return self
    }
    
    func build() throws -> NeuralNetwork {
        let building = descriptors.map { $0.build() }
        let network = building.compactMap{$0}
        
        guard network.count == building.count else {
            throw NNError.error(description: "Neurl netwotk can't be build!")
        }
        
        return NeuralNetwork(network: network)
    }
    
    
    private class LayerDescriptor {
        var dataType: BNNSDataType!
        var input: NNShape!
        var output: NNShape!
        
        func build() -> NNFilter? {
            return nil
        }
    }
    
    private class ConvolutionLayerDescriptor : LayerDescriptor {
        var kernel: (width: Int, height: Int)!
        var stride: (x: Int, y: Int)!
        var weights: [Float32]!
        var bias: [Float32]!
        var activation: BNNSActivationFunction!
        
        override func build() -> NNFilter? {
            
            let x_padding: Int = (stride.x * (output.width - 1) + kernel.width - input.width) / 2
            let y_padding: Int = (stride.y * (output.height - 1) + kernel.height - input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: input.width, height: input.height, channels: input.channels, row_stride: input.width, image_stride: input.width * input.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            var imageStackOut = BNNSImageStackDescriptor(width: output.width, height: output.height, channels: output.channels, row_stride: output.width, image_stride: output.width * output.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: weights, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let bias_data = BNNSLayerData(data: bias, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let activ = BNNSActivation(function: activation, alpha: 0, beta: 0)
            
            var layerParams = BNNSConvolutionLayerParameters(x_stride: stride.x, y_stride: stride.y, x_padding: pad.x, y_padding: pad.y, k_width: kernel.width, k_height: kernel.height, in_channels: input.channels, out_channels: output.channels, weights: weights_data, bias: bias_data, activation: activ)
            
            guard let convolve = BNNSFilterCreateConvolutionLayer(&imageStackIn, &imageStackOut, &layerParams, nil)
                else { return nil }
            
            return NNFilter(filter: convolve, shape: output)
        }
    }
    
    private class MaxPoolingLayerDescriptor : LayerDescriptor {
        var kernel: (width: Int, height: Int)!
        
        override func build() -> NNFilter? {
            
            let stride = (x: kernel.width, y: kernel.height)
            
            let x_padding: Int = (stride.x * (output.width - 1) + kernel.width - input.width) / 2
            let y_padding: Int = (stride.y * (output.height - 1) + kernel.height - input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: input.width, height: input.height, channels: input.channels, row_stride: input.width, image_stride: input.width * input.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            var imageStackOut = BNNSImageStackDescriptor(width: output.width, height: output.height, channels: output.channels, row_stride: output.width, image_stride: output.width * output.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let bias_data = BNNSLayerData()
            let activ = BNNSActivation(function: BNNSActivationFunction.identity, alpha: 0, beta: 0)
            
            var layerParams = BNNSPoolingLayerParameters(x_stride: stride.x, y_stride: stride.y, x_padding: pad.x, y_padding: pad.y, k_width: kernel.width, k_height: kernel.height, in_channels: input.channels, out_channels: output.channels, pooling_function: BNNSPoolingFunction.max, bias: bias_data, activation: activ)
            
            guard let pool = BNNSFilterCreatePoolingLayer(&imageStackIn, &imageStackOut, &layerParams, nil)
                else { return nil }
            
            return NNFilter(filter: pool, shape: output)
        }
    }
    
    private class FullyConnectedLayerDescriptor : LayerDescriptor {
        var weights: [Float32]!
        var bias: [Float32]!
        var activation: BNNSActivationFunction!
        
        override func build() -> NNFilter? {
            
            var hiddenIn = BNNSVectorDescriptor(size: input.size, data_type: dataType, data_scale: 0, data_bias: 0)
            var hiddenOut = BNNSVectorDescriptor(size: output.size, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: weights, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let bias_data = BNNSLayerData(data: bias, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let activ = BNNSActivation(function: activation, alpha: 0, beta: 0)
            
            var layerParams = BNNSFullyConnectedLayerParameters(in_size: input.size, out_size: output.size, weights: weights_data, bias: bias_data, activation: activ)
            
            guard let layer = BNNSFilterCreateFullyConnectedLayer(&hiddenIn, &hiddenOut, &layerParams, nil)
                else { return nil }
            
            return NNFilter(filter: layer, shape: output)
        }
    }
}

