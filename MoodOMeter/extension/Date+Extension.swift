//
//  Date+Extension.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/5/23.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    func addMonth(by num: Int) -> Date? {
        var calendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.month = +num
        if let month = calendar.date(byAdding: dateComponents, to: self) {
            return month
        }
        
        return nil
    }
    
    func decreaseMonth(by num: Int) -> Date? {
        var calendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.month = -num
        if let month = calendar.date(byAdding: dateComponents, to: self) {
            return month
        }
        
        return nil
    }
    
}
