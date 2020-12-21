import UIKit
import FutureKit

extension Array where Element: Comparable {

    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

extension Future where Value == [Float] {
    
    func makePresenter() throws -> Future<Recognizer.Presenter> {
        transformed { values in
            try .init(values)
        }
    }
}

extension Future where Value == UIImage {    
    func convertOf(_ viewModel: Recognizer.ViewModel) throws -> Future<Recognizer.Presenter> {
        chained { value in
            return try viewModel.fetch(value)
        }
    }
    
    func animate<T: Animatable>(view: T) -> Future<Value> {
        chained { [unowned self] value in
            DispatchQueue.main.async {
                view.performSnapshot(value)
            }
            return self
        }
    }
}

extension Future where Value == Recognizer.Presenter {
    @discardableResult
    func apply<Type: Applyable>(to view: Type) -> Future<Void>{
        chained { value in
            let promise = Promise<Void>()
            DispatchQueue.main.async {
                view.apply(value)
                promise.resolve(with: ())
            }
            return promise
        }
    }
}
