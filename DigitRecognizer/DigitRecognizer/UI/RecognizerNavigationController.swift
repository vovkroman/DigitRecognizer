import UIKit

final class RecognizerNavigationController: UINavigationController, Transparentable {

    override func viewDidLoad() {
        super.viewDidLoad()
        transparentBar()
    }
}
