//
//  MainVm.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/5/23.
//

import Foundation
import Combine

class MainVM {
    static let Shared = MainVM()

    @Published var calendarData: [String: DiaryModel] = [:]
    @Published var selectedDate: (date: Date, data: DiaryModel?)? = nil
    
    var inTheData = [Date().toString(format: "yyyy")]
    var currentYear = Date().toString(format: "yyyy")
    
    private var cancellables = Set<AnyCancellable>()
    
    //testData
    let testData = [
        "2022.12.02" : DiaryModel(sticker: ["happy", "cry"], story: "neh", date: "2022.12.02"),
        "2023.01.20" : DiaryModel(sticker: ["happy", "cry", "happy", "happy", "happy"], story: "nehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehneh", date: "2023.01.20"),
        "2023.11.22" : DiaryModel(sticker: ["happy"], story: "", date: "2023.11.22"),
    ]
    
    init() {
        calendarData = testData
//        fetchCalendarData(for: Date())
    }
//    
//    func fetchCalendarData(for date: Date) {
//        Firebase.Shared.getDiaryData(date: date)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .finished:
////                    print("MainVM - fetch calendar data success")
//                    break
//                case .failure(let error):
//                    print("MainVM - fetch calendar data failed : \(error)")
//                }
//            } receiveValue: { (sticker, story, date, ID) in
//                self.calendarData[ID] = DiaryModel(sticker: sticker, story: story, date: date)
//            }.store(in: &cancellables)
//    }
    
    
    
}
