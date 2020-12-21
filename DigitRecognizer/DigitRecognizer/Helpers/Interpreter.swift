import UIKit

protocol ViewStatable: class {
    func onViewDidLoaded()
    func onViewWillAppear(is animated: Bool)
    func onViewDidAppear(is animated: Bool)
}

final class Interpreter: NSObject {
    @IBOutlet weak private(set) var titleDescription: UILabel!
    @IBOutlet weak private(set) var imageView: UIImageView!
    @IBOutlet weak private(set) var titleResult: UILabel!
}

extension Interpreter: Applyable {
    func apply(_ presenter: Recognizer.Presenter) {
        titleResult.isHidden = false
        titleDescription.attributedText = presenter.message
    }
}

extension Interpreter: ViewStatable {
    func onViewDidLoaded() {
        //initially setup views
    }
    
    func onViewWillAppear(is animated: Bool) {}
    
    func onViewDidAppear(is animated: Bool) {}
}
