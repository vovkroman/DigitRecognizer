import UIKit
import FutureKit

enum NodeError: Error {
    case argmaxNil
}

extension NodeError: CustomStringConvertible {
    var description: String {
        switch self {
        case .argmaxNil:
            return "Argmax method was defined as nill"
        }
    }
}

extension Recognizer {
    
    struct Node {
        let message: NSAttributedString
        
        init(_ outputs: [Float], threshold: Float = 0.65) throws {
            guard let digit = outputs.argmax() else {
                throw NodeError.argmaxNil
            }
            let guess = outputs[digit]
            var result: Result.Message = .default
            if guess > threshold {
                result = .sure(prob: guess, digit: digit)
            } else {
                result = .notSure(prob: guess)
            }
            message = result.attributedDescription
        }
    }
}

extension Recognizer {
    class ViewModel {
        private let model = Model()

        func fetch(_ anImage: UIImage) throws -> Future<Node> {
            return try model
                .fetch(by: anImage)
                .makePresenter()
        }
        
        init() {}
    }
}
