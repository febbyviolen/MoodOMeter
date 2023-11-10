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
                print(newDiary)
                newDiary?.sticker.append(new!)
            } else {
                newDiary = DiaryModel(sticker: [new!], story: "", date: date)
            }
        }
    }
    
    func addNewStoryToData(_ new: String?, date: String) {
        print("WriteDiaryVM - story added to newDiary")
        if new != nil {
            if newDiary != nil {
                newDiary?.story = new!
            } else {
                newDiary = DiaryModel(sticker: [], story: new!, date: date)
            }
        }
    }
    
    func saveToFirebase(completion: @escaping () -> Void) {
        var newStory: String?
        if let story = newDiary?.story,
           story != "오늘은 어떤 하루였나요?" {
            newStory = story
        }
        Firebase.Shared.addDiary(date: MainVM.Shared.selectedDate!.date, sticker: newDiary?.sticker ?? [], story: newStory ?? "") {
            MainVM.Shared.selectedDate = (MainVM.Shared.selectedDate!.date, nil)
            MainVM.Shared.selectedDate?.data = DiaryModel(sticker: self.newDiary?.sticker ?? [], story: newStory ?? "", date: MainVM.Shared.selectedDate!.date.toString(format: "yyyy.MM.dd"))
            
            print("Selected date is updated - : \(MainVM.Shared.selectedDate)")
            completion()
        }
    }
}
