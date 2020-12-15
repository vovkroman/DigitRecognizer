//
//  ResultInterpreter.swift
//  DigitRecognizer
//
//  Created by Roman Vovk on 15.12.2020.
//  Copyright © 2020 Roman Vovk. All rights reserved.
//

import UIKit

class Interpreter: NSObject {
    @IBOutlet weak var titleDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}

extension Interpreter: Applyable {
    func apply(_ presenter: Recognizer.Presenter) {
        titleDescription.text = "I sure for \(presenter.guess) that this is \(presenter.digit)"
    }
}
