import UIKit

protocol AttributedDescriptionable {
    var attributedDescription: NSAttributedString { get }
}

enum Result {
    enum Message {
        case notSure(prob: Float)
        case sure(prob: Float, digit: Int)
        case `default`
    }
}

extension UIFont {
    static var `default`: UIFont {
        return UIFont.systemFont(ofSize: 14.0)
    }
    
    static var bold: UIFont {
        return UIFont.boldSystemFont(ofSize: 14.0)
    }
}

extension String {
    var notSureAttributes: NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [.font: UIFont.bold,
                                               .foregroundColor: UIColor.red])
    }
    
    var sureAttributed: NSAttributedString {
        return NSAttributedString(string: self, attributes: [.font: UIFont.default,
                                                             .foregroundColor: UIColor.black])
    }
}

extension Result.Message: AttributedDescriptionable {
    var attributedDescription: NSAttributedString {
        switch self {
        case .notSure(_):
            return "Current image is about to hard to recognize.".notSureAttributes
        case .sure(let prob, let digit):
            return NSAttributedString.composing {
                "Current image has been recognzied as".sureAttributed
                NSAttributedString.bold(" \(digit) ", boldFont: .bold, color: .black)
                "with probability ".sureAttributed
                NSAttributedString.bold(String(format: "%.2f ", prob * 100) + "%", boldFont: .bold, color: .black)
            }
        case .default:
            return "No results to display".notSureAttributes
        }
    }
}
