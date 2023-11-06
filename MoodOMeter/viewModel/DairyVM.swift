//
//  DairyVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import Foundation

class DiaryVM {
    @Published var diaryData = [DiaryModel]()
    @Published var thisMonthData = [DiaryModel]()
    
    init() {
        self.diaryData.append(contentsOf: MainVM.Shared.sendData())
    }
    
    func getThisMonthData(date: String) {
        thisMonthData.removeAll()
        thisMonthData = diaryData.filter{$0.date.contains(date)}
    }
}
