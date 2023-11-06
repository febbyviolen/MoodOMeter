//
//  String+Extension.swift
//  tip-calculator
//
//  Created by Ebbyy on 11/4/23.
//

import Foundation

extension String {
    var doubleValue: Double? {
        Double(self)
    }
    
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.date(from: self)
    }
}
