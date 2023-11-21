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
    
    func addYear(by num: Int) -> Date? {
        var calendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.year = +num
        if let year = calendar.date(byAdding: dateComponents, to: self) {
            return year
        }
        
        return nil
    }
    
    func decreaseYear(by num: Int) -> Date? {
        var calendar = Calendar.current
        var dateComponents = DateComponents()
        
        dateComponents.year = -num
        if let year = calendar.date(byAdding: dateComponents, to: self) {
            return year
        }
        
        return nil
    }
    
    func setToMidnight() -> Date? {
        var str = self.toString(format: "yyyy-MM-dd")
        str += " 00:00:00"
        print(str)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        if let toDate = formatter.date(from: str) {
            print(toDate)
            return toDate
        } else {
            print("Failed to convert string to date.")
            return nil
        }
    }


    
}
