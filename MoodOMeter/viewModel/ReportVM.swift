//
//  ReportVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/7/23.
//

import UIKit
import Combine

class ReportVM {
    typealias MoodGraph = (name: String, num: Int)
    
    @Published var reportData = [DiaryModel]()
    @Published var thisMonthMoodData: [MoodGraph] = []
    
    var thisMonthData = [DiaryModel]()
    var currentYear = Date().toString(format: "yyyy")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getAndTransformData(MainVM.Shared.calendarData)
        observe()
    }
    
    private func observe() {
        MainVM.Shared.$calendarData
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                getAndTransformData(data)
                print("ReportVM - observe calendar data")
            }
            .store(in: &cancellables)
    }
  
    func getAndTransformData(_ dict: [String: DiaryModel]) {
        reportData.removeAll()
        let dataArr = dict.map{$0.value}.sorted(by: {$0.date < $1.date})
        reportData = dataArr
    }
    
    func getThisMonthData(date: String) {
//        thisMonthMoodData.removeAll()
        print("ReportVM - get This Month Data")
        thisMonthData = reportData.filter{$0.date.contains(date)}
        print("thisMonthData: \(thisMonthData)")
        
        var dict = [String: Int]()
        for i in thisMonthData {
            for j in i.sticker {
                dict[j] = (dict[j] ?? 0) + 1
            }
        }
        
        let sortedGraphData = sortGraphData(data: dict)
        var graphData = [MoodGraph]()
        for (i,j) in zip(sortedGraphData.0, sortedGraphData.1) {
            graphData.append((i,j))
        }
        thisMonthMoodData = graphData
        
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
