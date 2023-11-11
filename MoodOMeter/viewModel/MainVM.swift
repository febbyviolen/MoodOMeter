//
//  MainVm.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/5/23.
//

import Foundation
import Combine
import UserNotifications

class MainVM {
    static let Shared = MainVM()

    @Published var calendarData: [String: DiaryModel] = [:]
    @Published var selectedDate: (date: Date, data: DiaryModel?)? = (Date(), nil)
    @Published var appIsLocked = false
    
    var currentYear = Date().toString(format: "yyyy")
    private var userDefault = UserDefaults.standard
    
    private var cancellables = Set<AnyCancellable>()
    
    //testData
    let testData = [
        "2022.12.02" : DiaryModel(sticker: ["happy", "cry"], story: "neh", date: "2022.12.02"),
        "2023.01.20" : DiaryModel(sticker: ["happy", "cry", "happy", "happy", "happy"], story: "nehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehnehneh", date: "2023.01.20"),
        "2023.11.22" : DiaryModel(sticker: ["happy"], story: "", date: "2023.11.22"),
    ]
    
    func fetchCalendarData(for date: Date) {
        Firebase.Shared.getDiaryData(date: date)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
//                    print("MainVM - fetch calendar data success")
                    break
                case .failure(let error):
                    print("MainVM - fetch calendar data failed : \(error)")
                }
            } receiveValue: { (data) in
                self.calendarData = data
            }.store(in: &cancellables)
    }
    
    func checkInterruptedReceipt() {
        if userDefault.string(forKey: "needSendToServer") == "true" {
            if let url = Bundle.main.appStoreReceiptURL,
               let data = try? Data(contentsOf: url) {
                let receiptBase64 = data.base64EncodedString()
                // Send to server
                Firebase.Shared.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                    self.userDefault.set("false", forKey: "needSendToServer")
                })
            }
        }
    }
    
    func setupUser() {
        if userDefault.string(forKey: "userID") != nil {
            print("registered user sign in: \(userDefault.string(forKey: "userID"))")
            Firebase.Shared.getSubscriptionInfo()
            self.fetchCalendarData(for: Date())
        } else {
            Firebase.Shared.anonymSign {
                print("new user sign in")
                self.fetchCalendarData(for: Date())
            }
        }
    }
    
    //MARK: APP OPENED FUNC
    //check if passcode is activated or not
    func checkIsPasscodeActivated() {
        if userDefault.string(forKey: "password") != nil && userDefault.string(forKey: "password")?.count == 4 {
            appIsLocked = true
        }
        if userDefault.string(forKey: "bioPassword") == "true" {
            appIsLocked = true
        }
    }
    
    //MARK: FIRST DOWNLOAD
    //if user allow the notification, and hasn't open the settings it will initially set alarm at 10pm
    func setNotification() {
        if userDefault.string(forKey: "alarmSetting") == nil {
            // Request authorization for notifications
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { (granted, error) in
                    if granted {
                        // User granted permission
                        // Create notification content
                        let content = UNMutableNotificationContent()
                        content.title = String(format: NSLocalizedString("무디", comment: "")) //사실 무드오미터
                        content.body = String(format: NSLocalizedString("오늘 하루도 기록해보세요!", comment: ""))
                        content.sound = UNNotificationSound.default
                        
                        // Create date components for 10 PM
                        var dateComponents = DateComponents()
                        dateComponents.hour = self.userDefault.integer(forKey: "alarmTime") == 0 ? 22 : self.userDefault.integer(forKey: "alarmTime")
                        dateComponents.minute = self.userDefault.integer(forKey: "alarmMinute") == 0 ? 00 : self.userDefault.integer(forKey: "alarmMinute")
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        let request = UNNotificationRequest(identifier: "addDiaryNotification", content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) { error in
                            if let _ = error {
                                //                            print("error")
                            } else {
                                //                            print("not error")
                            }
                        }
                    } else {
                        // User denied permission or there was an error
                        print("Notification permission denied or error: \(error?.localizedDescription ?? "")")
                    }
                }
        }
    }
   
    //MARK: WIDGET
    private func setWidgetDate() {
        let UD = UserDefaults(suiteName: "group.febby.moody.widgetcache")
        UD?.set(Date(), forKey: "date")
    }
    
}
