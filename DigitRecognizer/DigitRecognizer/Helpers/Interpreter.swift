import UIKit

final class Interpreter: NSObject {
    @IBOutlet weak var titleDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}

extension Interpreter: Applyable {
    func apply(_ presenter: Recognizer.Presenter) {
        titleDescription.text = "I sure for \(presenter.guess) that this is \(presenter.digit)"
    }
}
