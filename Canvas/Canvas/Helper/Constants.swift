import UIKit.UIColor

enum Constant {
    enum Functional {
        static let delay: TimeInterval = 2.0
    }
    enum Display {
        static var scale: CGFloat = UIScreen.main.scale
    }
    enum Points {
        static let maxCount: Int = 200
    }
    enum Line {
        static let color: UIColor = .black
        static let width: CGFloat = 30
        static let opacity: Float = 1
    }
}
