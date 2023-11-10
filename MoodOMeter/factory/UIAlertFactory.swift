//
//  UIAlertFactory.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/10/23.
//

import UIKit

struct UIAlertFactory {
    static func buildYesNoAlert(title: String?,
                                message: String?, 
                                okAction: UIAlertAction,
                                noAction: UIAlertAction
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        okAction.titleTextColor = UIColor(named: "black2")
        noAction.titleTextColor = UIColor(named: "black2")
        
        alert.addAction(noAction)
        alert.addAction(okAction)
        return alert
    }
}
