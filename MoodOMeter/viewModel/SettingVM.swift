//
//  SettingVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import UIKit
import Combine
import FirebaseAuth

class SettingVM {
    
    @Published var alarmTimeChanged: (hour: Int, minute: Int)?
    
    let userdefault = UserDefaults.standard
    
    //MARK: ALARM
    func getAlarmHour() -> Int {
        return userdefault.integer(forKey: "alarmTime")
    }
    
    func getAlarmMinute() -> Int {
        return userdefault.integer(forKey: "alarmMinute")
    }
    
    func setAlarmHour(to hour: Int) {
        userdefault.set(hour, forKey: "alarmTime")
    }
    
    func setAlarmMinute(to minute: Int) {
        userdefault.set(minute, forKey: "alarmMinute")
    }
    
    func getAlarmSettedTime() -> String {
        let hour = getAlarmHour().toStringTimeFormat()
        let minute = getAlarmMinute().toStringTimeFormat()
        return hour + ":" + minute
    }
    
    func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = String(format: NSLocalizedString("무드오미터", comment: ""))
        content.body = String(format: NSLocalizedString("오늘 하루도 기록해보세요!", comment: ""))
        content.sound = UNNotificationSound.default
        
        // Create date components for 10 PM
        var dateComponents = DateComponents()
        dateComponents.hour = getAlarmHour() == 0 ? 22 : getAlarmHour()
        dateComponents.minute = getAlarmMinute() == 0 ? 00 : getAlarmMinute()
        
        // Create trigger for a daily recurring notification at 10 PM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "addDiaryNotification", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // Handle error in notification scheduling
                print("SettingVM - Error sending notification: \(error)")
            } else {
                // Notification scheduled successfully
            }
        }
    }
    
    func updateNotificationHours(newHour: Int, newMinute: Int) {
        print("SettingVM - notification hours updated \(newHour) \(newMinute)")
        // Get the current list of notification requests
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            // Iterate over the notification requests
            for request in notificationRequests {
                // Check if the request has a trigger of type UNCalendarNotificationTrigger
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    // Delete the current notification request
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["addDiaryNotification"])
                    
                    // Get the date components from the current trigger
                    var dateComponents = trigger.dateComponents
                    
                    // Update the hour component to the new hour value
                    dateComponents.hour = newHour
                    dateComponents.minute = newMinute
                    
                    // Create a new trigger with the updated date components
                    let updatedTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: trigger.repeats)
                    
                    // Create a new notification request with the updated trigger
                    let updatedRequest = UNNotificationRequest(identifier: "addDiaryNotification", content: request.content, trigger: updatedTrigger)
                    
                    // Schedule the updated notification request
                    UNUserNotificationCenter.current().add(updatedRequest) { error in
                        if let error = error {
                            // Handle error in notification scheduling
                            print("SettingVM - Error updating notification request: \(error)")
                        } else {
                            // Notification updated successfully
//                            print("Notification updated successfully")
                        }
                    }
                }
            }
        }
    }
    
    // === delete user ===
    func deleteUser(user: User?) {
        Firebase.Shared.deleteUser(user: user?.uid ?? "" , date: Date())
        self.userdefault.set(nil, forKey: "userID")
        self.userdefault.set(nil, forKey: "userEmail")
        self.userdefault.set("false", forKey: "premiumPass")
    }
}
