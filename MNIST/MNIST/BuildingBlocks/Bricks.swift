import Accelerate

struct Shape {
    let width: Int
    let height: Int
    let channels: Int
    
    var size: Int {
        get {
            return width * height * channels
        }
    }
}

typealias Kernel = (width: Int, height: Int)
typealias Stride = (x: Int, y: Int)

class Filter {
    let filter: BNNSFilter
    let shape: Shape
    
    init(filter: BNNSFilter, shape: Shape) {
        self.filter = filter
        self.shape = shape
    }
    
    deinit { BNNSFilterDestroy(filter) }
}
