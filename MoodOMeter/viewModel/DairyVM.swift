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
    
    var currentYear = Date().toString(format: "yyyy")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("dairyVM - init()")
        self.fetchCalendarData(for: Date())
    }
    
    func fetchCalendarData(for date: Date) {
        print("dairyVM - fetch calendar data")
        //        Firebase.Shared.getDiaryData(date: date)
        //            .receive(on: DispatchQueue.main)
        //            .sink { completion in
        //                switch completion {
        //                case .finished:
        //                    break
        //                case .failure(let error):
        //                    print("MainVM - fetch calendar data failed : \(error)")
        //                }
        //            } receiveValue: { (sticker, story, date, ID) in
        //                print("MainVM - fetch calendar data success")
        //                var dict = [String: DiaryModel]()
        //                dict[ID] = DiaryModel(sticker: sticker, story: story, date: date)
        //                self.getAndTransformData(dict)
        //            }.store(in: &cancellables)
        
        if date.toString(format: "yyyy") == "2023" {
            getAndTransformData([
                "2023.11.01" : DiaryModel(sticker: [], story: "asd", date: "2023.11.01"),
                "2023.11.03" : DiaryModel(sticker: ["cry", "cry", "cry", "cry", "cry"], story: "sdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsd", date: "2023.11.03"),
                "2023.11.05" : DiaryModel(sticker: ["cry"], story: "", date: "2023.11.05"),])
        } else {
            getAndTransformData([
                "2024.01.01" : DiaryModel(sticker: [], story: "asd", date: "2024.01.01"),
                "2024.01.03" : DiaryModel(sticker: ["cry", "cry", "cry", "cry", "cry"], story: "sdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsd", date: "2024.01.03"),
                "2023.11.05" : DiaryModel(sticker: ["cry"], story: "", date: "2024.01.05"),])
        }
    }
    
    func getAndTransformData(_ dict: [String: DiaryModel]) {
        print("dairyVM - get and transform data")
        let dataArr = dict.map{$0.value}.sorted(by: {$0.date < $1.date})
        diaryData = dataArr
    }
    
    func getThisMonthData(date: String) {
        print("dairyVM - get this month data")
        thisMonthData.removeAll()
        thisMonthData = diaryData.filter{$0.date.contains(date)}
    }
    
}
