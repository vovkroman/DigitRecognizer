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

/// Returns a future which succeedes when all the given futures succeed. If
/// any of the futures fail, the returned future also fails with that error.
@inlinable
public func zip<V1, V2, V3>(_ f1: Future<V1>, _ f2: Future<V2>, _ f3: Future<V3>) -> Future<(V1, V2, V3)> {
    return zip(f1, zip(f2, f3)).transformed { ($0.0, $0.1.0, $0.1.1) }
}

/// Returns a future that succeeded when all the given futures succeed.
/// The future contains the result of combining the `initialResult` with
/// the values of all the given future. If any of the futures fail, the
/// returned future also fails with that error.
@inlinable
public func reduce<V1, V2>(_ initialResult: V1, _ futures: [Future<V2>], _ combiningFunction: @escaping (V1, V2) -> V1) -> Future<V1> {
    futures.reduce(Promise(value: initialResult)) { lhs, rhs in
        return zip(lhs, rhs).transformed(with: combiningFunction)
    }
}

/// Returns a future which succeedes when all the given futures succeed. If
/// any of the futures fail, the returned future also fails with that error.
@inlinable
public func zip<V>(_ futures: [Future<V>]) -> Future<[V]> {
    return reduce([], futures) { $0 + [$1] }
}

@inlinable
public func ~><V1, V2>(f1: Future<V1>, transfromFunc: @escaping (V1) throws -> V2) -> Future<V2> {
    f1.transformed(with: transfromFunc)
}
