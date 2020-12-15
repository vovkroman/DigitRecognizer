import UIKit
import FutureKit
import MNIST

enum RecognizerError: Error {
    case cannotRecognize
}

extension Recognizer {
    
    class Model {
        private let ai = MNIST()
        
        let globalWorker = DispatchQueue(label: "com.personal.digitRecognizer.global")

        func fetch(by image: UIImage) -> Future<[Float]> {
            let worker = DispatchQueue(label: "com.personal.digitRecognizer.local",
                                       attributes: .concurrent,
                                       target: globalWorker)
            let promise = Promise<[Float]>()
            worker.async { [weak self] in
                guard let results = self?.ai?.predict(image: image) else {
                    promise.reject(with: RecognizerError.cannotRecognize)
                    return
                }
                promise.resolve(with: results)
            }
            return promise
        }
    }
}
