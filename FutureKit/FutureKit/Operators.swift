/// Operators with **Futures**;
/// Returns a future which succeedes when all the given futures succeed. If
/// any of the futures fail, the returned future also fails with that error.
@inlinable
public func zip<V1, V2>(_ f1: Future<V1>, _ f2: Future<V2>) -> Future<(V1, V2)> {
    let promise = Promise<(V1, V2)>()
    func observeFunc(result: Any) {
        guard let v1 = f1.result, let v2 = f2.result else { return }
        switch (v1, v2) {
        case (.success(let value1), .success(let value2)):
            promise.resolve(with: (value1, value2))
        case (.failure(let error), _):
            promise.reject(with: error)
        case (_, .failure(let error)):
            promise.reject(with: error)
        }
    }
    f1.observe(using: observeFunc)
    f2.observe(using: observeFunc)
    
    return promise
}
