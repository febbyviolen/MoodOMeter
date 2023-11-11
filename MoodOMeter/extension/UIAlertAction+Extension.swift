//
//  UIAlertAction+Extension.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/10/23.
//

import UIKit

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
