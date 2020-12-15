import UIKit
import FutureKit

extension Recognizer {
    
    struct Presenter {
        let digit: String
        let guess: Float
    }
    
    class ViewModel {
        
        private let model = Model()
        
        func fetch(_ anImage: UIImage) -> Future<[Presenter]> {
            let promise = Promise<[Presenter]>()
            model.fetch(by: anImage).observe { (result) in
                switch result {
                case .failure(let error):
                    promise.reject(with: error)
                    break
                case .success(let outputs):
                    let presenters = outputs.enumerated().compactMap{ Presenter(digit: "\($0)", guess: $1) }
                    promise.resolve(with: presenters.sorted(by: { $0.guess > $1.guess }))
                }
            }
            return promise
        }
        
        init() {}
    }
}
