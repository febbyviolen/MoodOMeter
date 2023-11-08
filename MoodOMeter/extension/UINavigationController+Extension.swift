//
//  UINavigationController+Extension.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import UIKit

extension UINavigationController {
    func viewControllerBeforeCurrent() -> UIViewController? {
        if let currentIndex = viewControllers.firstIndex(where: { $0 === topViewController }) {
            if currentIndex > 0 {
                return viewControllers[currentIndex - 1]
            }
        }
        
        return nil
    }
}
