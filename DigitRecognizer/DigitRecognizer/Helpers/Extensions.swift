import UIKit
import FutureKit

extension Array where Element: Comparable {
    /// Description: extenstion to [Array](https://developer.apple.com/documentation/swift/array) to
    /// find index of the largest element in unsorted array
    /// - Compexity: O(n)
    @inlinable
    public func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    /// Description: extenstion to [Array](https://developer.apple.com/documentation/swift/array) to
    /// find index of the smallest element in unsorted array
    /// - Compexity: O(n)
    @inlinable
    public func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

extension Future where Value == [Float] {
    
    func interpret() -> Future<Recognizer.Presenter> {
        transformed { values in
            try .init(values)
        }
    }
}

extension Future where Value == UIImage {    
    func convertToPresenter(_ viewModel: Recognizer.ViewModel) -> Future<Recognizer.Presenter> {
        chained { value in
            return viewModel.fetch(value)
        }
    }
    
    func animate<T: Animatable>(view: T) -> Future<Value> {
        chained { value in
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
