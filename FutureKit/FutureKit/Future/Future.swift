import Foundation

open class Future<Value> {
    
    public typealias Result = Swift.Result<Value, Error>
    
    @usableFromInline
    internal var result: Result? {
        // Observe whenever a result is assigned, and report it:
        didSet { result.map(report) }
    }
    
    @usableFromInline
    internal var callbacks = [(Result) -> Void]()
    
    @inlinable
    public func observe(using callback: @escaping (Result) -> Void) {
        // If a result has already been set, call the callback directly:
        if let result = result {
            return callback(result)
        }
        
        callbacks.append(callback)
    }
    
    @usableFromInline
    internal func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    @inlinable
    public init() {}
}
