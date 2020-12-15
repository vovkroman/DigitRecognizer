import UIKit
import FutureKit

struct Presenter {
    let digit: String
    let guess: Float
    
    init(_ outputs: [Float]) throws {
        guard let digit = outputs.argmax() else {
            throw RecognizerError.cannotRecognize
        }
        self.digit = "\(digit)"
        self.guess = outputs[digit]
    }
}

extension Recognizer {
    
    class ViewModel {
        
        private let model = Model()
        private var item: Presenter?
        
        func fetch(_ anImage: UIImage) -> Future<Presenter> {
            return model
                .fetch(by: anImage)
                .interpret()
        }
        
        init() {}
    }
}
