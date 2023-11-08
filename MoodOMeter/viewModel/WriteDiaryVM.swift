//
//  WriteDiaryVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/7/23.
//

import Foundation

class WriteDiaryVM {
    @Published var newDiary: DiaryModel?
    @Published var newAddedSticker: String?
    
    func addNewStickerToData(_ new: String?, date: String) {
        if new != nil {
            if newDiary != nil {
                newDiary?.sticker.append(new!)
            } else {
                newDiary = DiaryModel(sticker: [new!], story: "", date: date)
            }
        }
    }
    
    func addNewStoryToData(_ new: String?, date: String) {
        if new != nil {
            if newDiary != nil {
                newDiary?.story = new!
            } else {
                newDiary = DiaryModel(sticker: [], story: new!, date: date)
            }
        }
    }
}
