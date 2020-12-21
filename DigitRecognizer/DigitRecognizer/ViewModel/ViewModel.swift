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
        let message: NSAttributedString
        
        init(_ outputs: [Float], threshold: Float = 0.65) throws {
            guard let digit = outputs.argmax() else {
                throw PresenterError.argmaxNil
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

        func fetch(_ anImage: UIImage) throws -> Future<Presenter> {
            return try model
                .fetch(by: anImage)
                .makePresenter()
        }
        
        init() {}
    }
}
