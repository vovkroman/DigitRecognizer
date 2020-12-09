import Foundation

open class Future<Value> {
    
    @usableFromInline
    typealias Result = Swift.Result<Value, Error>
    
    @usableFromInline
    var result: Result? {
        // Observe whenever a result is assigned, and report it:
        didSet { result.map(report) }
    }
    
    @usableFromInline
    var callbacks = [(Result) -> Void]()
    
    @inlinable
    func observe(using callback: @escaping (Result) -> Void) {
        // If a result has already been set, call the callback directly:
        if let result = result {
            return callback(result)
        }
        
        callbacks.append(callback)
    }
    
    @usableFromInline
    func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    @usableFromInline
    init() {}
}
