import Foundation

extension Array where Element == Float {
    func softmax() -> Array {
        var sum: Float = 0
        for item in self {
            sum = sum + exp(item)
        }
        return compactMap{ exp($0) / sum }
    }
}
