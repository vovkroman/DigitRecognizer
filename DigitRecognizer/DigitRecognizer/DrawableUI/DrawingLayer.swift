import UIKit

final class DrawingLayer: CAShapeLayer {
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension DrawingLayer: Archivable {    
    
    func unarchive(data: Data) throws -> DrawingLayer? {
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? DrawingLayer
    }
    
    func archive(is secureCoding: Bool = false) throws  -> Data {
        return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: secureCoding)
    }
}

extension DrawingLayer {
    func applyStyle(_ styler: Styler) {
        styler.applyStyle(to: self)
    }
}
