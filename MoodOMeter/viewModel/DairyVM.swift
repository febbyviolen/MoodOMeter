//
//  DairyVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import Foundation
import Combine

class DiaryVM {
    @Published var diaryData = [DiaryModel]()
    @Published var thisMonthData = [DiaryModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    let currentDateSubject = CurrentValueSubject<Date, Never>(Date())
    
    init() {
        print("dairyVM - init()")
//        self.fetchCalendarData(for: Date())
        getAndTransformData(MainVM.Shared.calendarData)
        observe()
    }
    
    private func observe() {
        MainVM.Shared.$calendarData
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                getAndTransformData(data)
                print("DiaryVM - get the data")
            }
            .store(in: &cancellables)
        
        $diaryData
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("dairyVM - this diaryData bind")
                self.getThisMonthData(date: self.currentDateSubject.value.toString(format: "yyyy.MM"))
            }
            .store(in: &cancellables)
    }
    
    func getAndTransformData(_ dict: [String: DiaryModel]) {
        print("dairyVM - get and transform data")
        let dataArr = dict.map{$0.value}.sorted(by: {$0.date > $1.date})
        diaryData = dataArr
    }
    
    func getThisMonthData(date: String) {
        print("dairyVM - get this month data : \(date)")
//        thisMonthData.removeAll()
        thisMonthData = diaryData.filter{$0.date.contains(date)}
    }
    
}
