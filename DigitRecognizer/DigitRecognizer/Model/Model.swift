import UIKit
import FutureKit
import MNIST

enum MNISTError: Error {
    case cannotRecognize
}

extension MNISTError: CustomStringConvertible {
    var description: String {
        switch self {
        case .cannotRecognize:
            return "MNIST.framework returns nil for some reason"
        }
    }
}

protocol Predictable: class {
    func predict(by image: UIImage) throws -> [Float]
}

extension MNIST: Predictable {
    func predict(by image: UIImage) throws -> [Float] {
        try predict(image: image)
    }
}

protocol Modelable {
    func fetch(by image: UIImage) -> Future<[Float]>
}

extension Recognizer {
    
    class Model: Modelable {
        private let ai: Predictable?
        private let globalWorker = DispatchQueue(label: "com.personal.digitRecognizer.global")

        func fetch(by image: UIImage) -> Future<[Float]> {
            let promise = Promise<[Float]>()
            globalWorker.async { [weak self] in
                guard let results = try? self?.ai?.predict(by: image) else {
                    promise.reject(with: MNISTError.cannotRecognize)
                    return
                }
                promise.resolve(with: results)
            }
            return promise
        }
        
        init(_ ai: Predictable? = MNIST()) {
            self.ai = ai
        }
    }
}
