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

struct Kernel {
    let width: Int
    let height: Int
}

struct Stride {
    let x: Int
    let y: Int
}

class Filter {
    let filter: BNNSFilter
    let shape: Shape
    
    init(filter: BNNSFilter, shape: Shape) {
        self.filter = filter
        self.shape = shape
    }
    
    deinit { BNNSFilterDestroy(filter) }
}
