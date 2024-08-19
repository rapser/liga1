//
//  TextField+Extension.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit

extension UITextField {
    func addDoneButtonOnKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Hecho", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        self.inputAccessoryView = toolbar
    }

    @objc private func doneButtonTapped() {
        self.resignFirstResponder()
    }
}
