import Foundation

open class Promise<Value>: Future<Value> {
    
    @inlinable
    init(value: Value? = nil) {
        super.init()

        // If the value was already known at the time the promise
        // was constructed, we can report it directly:
        result = value.map(Result.success)
    }
    
    @inlinable
    func resolve(with value: Value) {
        result = .success(value)
    }

    @inlinable
    func reject(with error: Error) {
        result = .failure(error)
    }
}
