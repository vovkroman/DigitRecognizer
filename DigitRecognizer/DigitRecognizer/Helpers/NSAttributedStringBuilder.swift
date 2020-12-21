import UIKit

@_functionBuilder
class NSAttributedStringBuilder {
    static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        
        return components.reduce(into: result) { (result, current) in result.append(current) }
    }
}

extension NSAttributedString {
    class func composing(@NSAttributedStringBuilder _ parts: () -> NSAttributedString) -> NSAttributedString {
        return parts()
    }
}

extension NSAttributedString {
    static func bold(_ value: String, boldFont: UIFont, color: UIColor) -> NSAttributedString {
        let attributes: [NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor: color
        ]
        return NSAttributedString(string: value, attributes:attributes)
    }
}
