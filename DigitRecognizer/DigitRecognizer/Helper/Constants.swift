import UIKit.UIColor

enum Constant {
    enum Display {
        static var scale: CGFloat = UIScreen.main.scale
    }
    enum Points {
        static let maxCount: Int = 200
    }
    enum Line {
        static let color: UIColor = .black
        static let width: CGFloat = 5
        static let opacity: Float = 1
    }
}
