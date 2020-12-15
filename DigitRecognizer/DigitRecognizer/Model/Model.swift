import UIKit
import FutureKit
import MNIST

enum MNISTError: Error {
    case cannotRecognize
}

extension Recognizer {
    
    class Model {
        private let ai = MNIST()
        
        let globalWorker = DispatchQueue(label: "com.personal.digitRecognizer.global")

        func fetch(by image: UIImage) -> Future<[Float]> {
            let promise = Promise<[Float]>()
            globalWorker.async { [weak self] in
                guard let results = try? self?.ai?.predict(image: image) else {
                    promise.reject(with: MNISTError.cannotRecognize)
                    return
                }
                promise.resolve(with: results)
            }
            return promise
        }
    }
}
