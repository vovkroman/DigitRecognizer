import Accelerate

enum NNLayerError: String, Error {
    case abstractLayerError = "An abstract layer"
    case convolutionLayerError = "A convolutional layer"
    case maxPoolingLayerError = "A maxpolling layer"
    case fullyConnectedLayerError = "A fully connceted layer"
}

extension NNLayerError: CustomStringConvertible {
    var description: String {
        return rawValue + "can't be created!"
    }
}

protocol Buildable {
    func build() throws -> Filter
}

enum Descriptor {}

extension Descriptor {
    
    class LayerBuilder {
        var dataType: BNNSDataType = .float
        var input: Shape = .default
        var output: Shape = .default
    }
    
    class Layer {
        typealias LayerBuilderClosure = (LayerBuilder) -> ()
        
        let _dataType: BNNSDataType
        let _input: Shape
        var _output: Shape
        
        func build() throws -> Filter {
            throw NNLayerError.abstractLayerError
        }
        
        convenience init(block: LayerBuilderClosure) {
            let builder = LayerBuilder()
            block(builder)
            
            self.init(builder: builder)
        }
        
        init(builder: LayerBuilder) {
            _dataType = builder.dataType
            _input = builder.input
            _output = builder.output
        }
    }
}

extension Descriptor {
    
    final class ConvolutionLayerBuilder: LayerBuilder {
        var kernel: Kernel = .default
        var stride: Stride = .default
        var weights: [Float32] = []
        var bias: [Float32] = []
        var activation: BNNSActivationFunction = .identity
    }
    
    final class ConvolutionLayer: Layer {
        typealias ConvolutionLayerBuilderClosure = (ConvolutionLayerBuilder) -> ()
        
        private let _kernel: Kernel
        private let _stride: Stride
        private let _weights: [Float32]
        private let _bias: [Float32]
        private let _activation: BNNSActivationFunction
        
        convenience init(block: ConvolutionLayerBuilderClosure) {
            let builder = ConvolutionLayerBuilder()
            block(builder)
            self.init(builder: builder)
        }
        
        init(builder: ConvolutionLayerBuilder) {
            _kernel = builder.kernel
            _stride = builder.stride
            _weights = builder.weights
            _bias = builder.bias
            _activation = builder.activation
            super.init(builder: builder)
        }
        
        override func build() throws -> Filter {
            
            let x_padding: Int = (_stride.x * (_output.width - 1) + _kernel.width - _input.width) / 2
            let y_padding: Int = (_stride.y * (_output.height - 1) + _kernel.height - _input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: _input.width,
                                                        height: _input.height,
                                                        channels: _input.channels,
                                                        row_stride: _input.width,
                                                        image_stride: _input.width * _input.height,
                                                        data_type: _dataType,
                                                        data_scale: 0,
                                                        data_bias: 0)
            var imageStackOut = BNNSImageStackDescriptor(width: _output.width,
                                                         height: _output.height,
                                                         channels: _output.channels,
                                                         row_stride: _output.width,
                                                         image_stride: _output.width * _output.height,
                                                         data_type: _dataType, data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: _weights,
                                             data_type: _dataType,
                                             data_scale: 0,
                                             data_bias: 0,
                                             data_table: nil)
            let bias_data = BNNSLayerData(data: _bias,
                                          data_type: _dataType,
                                          data_scale: 0,
                                          data_bias: 0,
                                          data_table: nil)
            let activ = BNNSActivation(function: _activation, alpha: 0, beta: 0)
            
            var layerParams = BNNSConvolutionLayerParameters(x_stride: _stride.x,
                                                             y_stride: _stride.y,
                                                             x_padding: pad.x,
                                                             y_padding: pad.y,
                                                             k_width: _kernel.width,
                                                             k_height: _kernel.height,
                                                             in_channels: _input.channels,
                                                             out_channels: _output.channels,
                                                             weights: weights_data,
                                                             bias: bias_data,
                                                             activation: activ)
            
            guard let convolve = BNNSFilterCreateConvolutionLayer(&imageStackIn, &imageStackOut, &layerParams, nil) else {
                throw NNLayerError.convolutionLayerError
            }
            
            return Filter(filter: convolve, shape: _output)
        }
    }
}

extension Descriptor {
    final class MaxPoolingLayerBuilder: LayerBuilder {
        var kernel: Kernel = .default
    }
    
    final class MaxPoolingLayer: Layer {
        typealias MaxPoolingLayerBuilderClosure = (MaxPoolingLayerBuilder) -> ()
        private let _kernel: Kernel
        
        override func build() throws -> Filter {
            
            let stride = (x: _kernel.width, y: _kernel.height)
            
            let x_padding: Int = (stride.x * (_output.width - 1) + _kernel.width - _input.width) / 2
            let y_padding: Int = (stride.y * (_output.height - 1) + _kernel.height - _input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: _input.width,
                                                        height: _input.height,
                                                        channels: _input.channels,
                                                        row_stride: _input.width,
                                                        image_stride: _input.width * _input.height,
                                                        data_type: _dataType,
                                                        data_scale: 0, data_bias: 0)
            var imageStackOut = BNNSImageStackDescriptor(width: _output.width,
                                                         height: _output.height,
                                                         channels: _output.channels, row_stride: _output.width,
                                                         image_stride: _output.width * _output.height,
                                                         data_type: _dataType,
                                                         data_scale: 0, data_bias: 0)
            
            let bias_data = BNNSLayerData()
            let activ = BNNSActivation(function: .identity,
                                       alpha: 0,
                                       beta: 0)
            
            var layerParams = BNNSPoolingLayerParameters(x_stride: stride.x,
                                                         y_stride: stride.y,
                                                         x_padding: pad.x,
                                                         y_padding: pad.y,
                                                         k_width: _kernel.width,
                                                         k_height: _kernel.height,
                                                         in_channels: _input.channels,
                                                         out_channels: _output.channels,
                                                         pooling_function: .max,
                                                         bias: bias_data,
                                                         activation: activ)
            
            guard let pool = BNNSFilterCreatePoolingLayer(&imageStackIn, &imageStackOut, &layerParams, nil) else {
                throw NNLayerError.maxPoolingLayerError
            }
            return Filter(filter: pool, shape: _output)
        }
        
        convenience init(block: MaxPoolingLayerBuilderClosure) {
            let builder = MaxPoolingLayerBuilder()
            block(builder)
            self.init(builder: builder)
        }
        
        init(builder: MaxPoolingLayerBuilder) {
            _kernel = builder.kernel
            super.init(builder: builder)
        }
    }
}

extension Descriptor {
    final class FullyConnectedLayerBuilder: LayerBuilder {
        var weights: [Float32] = []
        var bias: [Float32] = []
        var activation: BNNSActivationFunction = .identity
    }
    
    final class FullyConnectedLayer: Layer {
        typealias FullyConnectedLayerBuilderClosure = (FullyConnectedLayerBuilder) -> ()
        private let _weights: [Float32]
        private let _bias: [Float32]
        private let _activation: BNNSActivationFunction
        
        
        override func build() throws -> Filter {
            var hiddenIn = BNNSVectorDescriptor(size: _input.size,
                                                data_type: _dataType,
                                                data_scale: 0, data_bias: 0)
            var hiddenOut = BNNSVectorDescriptor(size: _output.size,
                                                 data_type: _dataType,
                                                 data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: _weights,
                                             data_type: _dataType,
                                             data_scale: 0,
                                             data_bias: 0, data_table: nil)
            let bias_data = BNNSLayerData(data: _bias,
                                          data_type: _dataType,
                                          data_scale: 0,
                                          data_bias: 0,
                                          data_table: nil)
            let activ = BNNSActivation(function: _activation,
                                       alpha: 0,
                                       beta: 0)
            
            var layerParams = BNNSFullyConnectedLayerParameters(in_size: _input.size,
                                                                out_size: _output.size,
                                                                weights: weights_data,
                                                                bias: bias_data,
                                                                activation: activ)
            
            guard let layer = BNNSFilterCreateFullyConnectedLayer(&hiddenIn, &hiddenOut, &layerParams, nil) else {
                throw NNLayerError.fullyConnectedLayerError
            }
            return Filter(filter: layer, shape: _output)
        }
        
        
        convenience init(block: FullyConnectedLayerBuilderClosure) {
            let builder = FullyConnectedLayerBuilder()
            block(builder)
            self.init(builder: builder)
        }
        
        init(builder: FullyConnectedLayerBuilder) {
            _weights = builder.weights
            _bias = builder.bias
            _activation = builder.activation
            super.init(builder: builder)
        }
    }
}
