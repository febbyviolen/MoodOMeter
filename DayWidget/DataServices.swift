//
//  DataServices.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/19/23.
//

import Foundation

struct DataServices {
    var userDefault = UserDefaults(suiteName: "group.febby.moody.widgetcache")
    
    func getData() -> (String, Date) {
        let img = userDefault?.value(forKey: "img") as? String ?? ""
        let date = userDefault?.value(forKey: "date") as? Date ?? Date()
        print(img)
        return (img, date)
    }
    
    func checkIfNewDay(_ newDate: Date) {
        userDefault?.set("", forKey: "img")
        userDefault?.set(newDate, forKey: "date")
    }
}
