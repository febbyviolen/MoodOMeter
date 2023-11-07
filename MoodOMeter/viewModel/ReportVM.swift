//
//  ReportVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/7/23.
//

import UIKit
import Combine

class ReportVM {
    typealias MoodGraph = (name: String, age: Int)
    
    @Published var reportData = [DiaryModel]()
    @Published var thisMonthMoodData: [MoodGraph] = []
    
    var thisMonthData = [DiaryModel]()
    var currentYear = Date().toString(format: "yyyy")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchCalendarData(for: Date())
    }
    
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
        let dataArr = dict.map{$0.value}.sorted(by: {$0.date < $1.date})
        reportData = dataArr
    }
    
    func getThisMonthData(date: String) {
        thisMonthData.removeAll()
        thisMonthMoodData.removeAll()
        thisMonthData = reportData.filter{$0.date.contains(date)}
        
        var dict = [String: Int]()
        for i in thisMonthData {
            for j in i.sticker {
                dict[j] = (dict[j] ?? 0) + 1
            }
        }
        
        let sortedGraphData = sortGraphData(data: dict)
        for (i,j) in zip(sortedGraphData.0, sortedGraphData.1) {
            thisMonthMoodData.append((i,j))
        }
        
    }
    
    private func sortGraphData(data: [String: Int]) -> ([String], [Int]) {
        let graphItemTitleSorted = data.sorted { (item1, item2) in
            if item1.value == item2.value {
                return item1.key < item2.key
            } else {
                return item1.value > item2.value
            }
        }.map { $0.key }

        let graphItemCountSorted = data.sorted { (item1, item2) in
            if item1.value == item2.value {
                return item1.key < item2.key
            } else {
                return item1.value > item2.value
            }
        }.map { $0.value }
        
        return (graphItemTitleSorted, graphItemCountSorted)
    }
    
}
