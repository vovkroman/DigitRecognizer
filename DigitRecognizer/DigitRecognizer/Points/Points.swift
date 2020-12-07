import UIKit

typealias Items = ContiguousArray<CGPoint>

protocol ItemsTracker: class {
    func didGainMaxCount(_ line: Items)
}

class Points {
    private var _line: Items {
        didSet {
            if count > _maxCount {
                _delegate?.didGainMaxCount(_line)
            }
        }
    }
    
    private let _maxCount: Int
    
    private weak var _delegate: ItemsTracker?
    
    init(_ maxCount: Int, tracker: ItemsTracker? = nil) {
        _maxCount = maxCount
        _line = []
        _line.reserveCapacity(_maxCount)
        _delegate = tracker
    }
    
    var last: CGPoint {
        return _line.last ?? .zero
    }
    
    var first: CGPoint? {
        return _line.first
    }
    
    var count: Int {
        return _line.count
    }
    
    subscript(index: Int) -> CGPoint {
        return _line[index]
    }
    
    func setDelegate(_ delegate: ItemsTracker?) {
        guard let delegate = delegate else { return }
        _delegate = delegate
    }
    
    func removeAll() {
        _line.removeAll()
    }
    
    func add(_ new: CGPoint) {
        _line.append(new)
    }
}

extension Points: Sequence {
    func makeIterator() -> IndexingIterator<Items> {
        return _line.makeIterator()
    }
}
