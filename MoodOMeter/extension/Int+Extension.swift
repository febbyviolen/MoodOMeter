//
//  Int+Extension.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import Foundation

extension Int {
    func toStringTimeFormat() -> String {
        if String(self).count == 1 {
            return "0" + String(self)
        }
        return String(self)
    }
}
