import Accelerate

protocol Buildable {
    func build() throws -> Filter
}

enum Descriptor {}

extension Descriptor {
    class Layer {
        var dataType: BNNSDataType = .float
        var input: Shape = .default
        var output: Shape = .default
        
        func build() throws -> Filter {
            fatalError("Abstarct layer can't be built")
        }
    }
}

extension Descriptor {
    final class ConvolutionLayer: Layer {
        var kernel: Kernel = .default
        var stride: Stride = .default
        var weights: [Float32] = []
        var bias: [Float32] = []
        var activation: BNNSActivationFunction = .identity
        
        override func build() throws -> Filter {
            
            let x_padding: Int = (stride.x * (output.width - 1) + kernel.width - input.width) / 2
            let y_padding: Int = (stride.y * (output.height - 1) + kernel.height - input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: input.width, height: input.height, channels: input.channels, row_stride: input.width, image_stride: input.width * input.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            var imageStackOut = BNNSImageStackDescriptor(width: output.width, height: output.height, channels: output.channels, row_stride: output.width, image_stride: output.width * output.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: weights, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let bias_data = BNNSLayerData(data: bias, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let activ = BNNSActivation(function: activation, alpha: 0, beta: 0)
            
            var layerParams = BNNSConvolutionLayerParameters(x_stride: stride.x, y_stride: stride.y, x_padding: pad.x, y_padding: pad.y, k_width: kernel.width, k_height: kernel.height, in_channels: input.channels, out_channels: output.channels, weights: weights_data, bias: bias_data, activation: activ)
            
            guard let convolve = BNNSFilterCreateConvolutionLayer(&imageStackIn, &imageStackOut, &layerParams, nil) else {
                fatalError("ConvolutionLayer can't be built")
            }
            
            return Filter(filter: convolve, shape: output)
        }
    }
}

extension Descriptor {
    final class MaxPoolingLayer: Layer {
        var kernel: Kernel = .default
        
        override func build() throws -> Filter {
            
            let stride = (x: kernel.width, y: kernel.height)
            
            let x_padding: Int = (stride.x * (output.width - 1) + kernel.width - input.width) / 2
            let y_padding: Int = (stride.y * (output.height - 1) + kernel.height - input.height) / 2
            let pad = (x: x_padding, y: y_padding)
            
            var imageStackIn = BNNSImageStackDescriptor(width: input.width, height: input.height, channels: input.channels, row_stride: input.width, image_stride: input.width * input.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            var imageStackOut = BNNSImageStackDescriptor(width: output.width, height: output.height, channels: output.channels, row_stride: output.width, image_stride: output.width * output.height, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let bias_data = BNNSLayerData()
            let activ = BNNSActivation(function: BNNSActivationFunction.identity, alpha: 0, beta: 0)
            
            var layerParams = BNNSPoolingLayerParameters(x_stride: stride.x, y_stride: stride.y, x_padding: pad.x, y_padding: pad.y, k_width: kernel.width, k_height: kernel.height, in_channels: input.channels, out_channels: output.channels, pooling_function: BNNSPoolingFunction.max, bias: bias_data, activation: activ)
            
            guard let pool = BNNSFilterCreatePoolingLayer(&imageStackIn, &imageStackOut, &layerParams, nil) else {
                fatalError("MaxPoolingLayer can't be built")
            }
            
            return Filter(filter: pool, shape: output)
        }
    }
}

extension Descriptor {
    final class FullyConnectedLayer: Layer {
        var weights: [Float32] = []
        var bias: [Float32] = []
        var activation: BNNSActivationFunction = .identity
        
        override func build() throws -> Filter {
            var hiddenIn = BNNSVectorDescriptor(size: input.size, data_type: dataType, data_scale: 0, data_bias: 0)
            var hiddenOut = BNNSVectorDescriptor(size: output.size, data_type: dataType, data_scale: 0, data_bias: 0)
            
            let weights_data = BNNSLayerData(data: weights, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let bias_data = BNNSLayerData(data: bias, data_type: dataType, data_scale: 0, data_bias: 0, data_table: nil)
            let activ = BNNSActivation(function: activation, alpha: 0, beta: 0)
            
            var layerParams = BNNSFullyConnectedLayerParameters(in_size: input.size, out_size: output.size, weights: weights_data, bias: bias_data, activation: activ)
            
            guard let layer = BNNSFilterCreateFullyConnectedLayer(&hiddenIn, &hiddenOut, &layerParams, nil) else {
                fatalError("FullyConnectedLayer can't be built")
            }
            return Filter(filter: layer, shape: output)
        }
    }

}
