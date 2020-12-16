import UIKit
import FutureKit

enum PresenterError: Error {
    case argmaxNil
}

extension PresenterError: CustomStringConvertible {
    var description: String {
        switch self {
        case .argmaxNil:
            return "Argmax method was defined as nill"
        }
    }
}

extension Recognizer {
    
    struct Presenter {
        let digit: String
        let guess: Float
        
        init(_ outputs: [Float]) throws {
            guard let digit = outputs.argmax() else {
                throw PresenterError.argmaxNil
            }
            self.digit = "\(digit)"
            self.guess = outputs[digit]
        }
    }
}

extension Recognizer {
    class ViewModel {
        private let model = Model()

        func fetch(_ anImage: UIImage) -> Future<Presenter> {
            return model
                .fetch(by: anImage)
                .interpret()
        }
        
        init() {}
    }
}
