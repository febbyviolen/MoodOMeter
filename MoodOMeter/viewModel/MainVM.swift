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

    @Published var calendarData: [String: DiaryModel] = [
        "2023.11.01" : DiaryModel(sticker: [], story: "asd", date: "2023.11.01"),
        "2023.11.03" : DiaryModel(sticker: ["cry", "cry", "cry", "cry", "cry"], story: "sdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsdsd", date: "2023.11.03"),
        "2023.11.05" : DiaryModel(sticker: ["cry"], story: "", date: "2023.11.05"),]
    
    var currentYear = Date().toString(format: "yyyy")
    @Published var selectedDate: (date: Date, data: DiaryModel?)? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCalendarData(for date: Date) {
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
//                self.calendarData[ID] = DiaryModel(sticker: sticker, story: story, date: date)
//            }.store(in: &cancellables)
    }
    
    
    
}
