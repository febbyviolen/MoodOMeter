//
//  SettingViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit
import NVActivityIndicatorView
import Combine
import CombineCocoa
import FirebaseAuth

class SettingVC: UIViewController {
    
    @IBOutlet weak var deleteAccountLabel: UILabel!
    @IBOutlet weak var deleteAccountView: UIView!
    @IBOutlet weak var rateAppView: UIView!
    @IBOutlet weak var googleAuthView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var alarmClockView: UIView!
    @IBOutlet weak var alarmSwitchView: UIView!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var buySubscribeBackground: UIView!
    @IBOutlet weak var buySubscribeLable: UILabel!
    @IBOutlet weak var timeClockLabel: UILabel!
    
    let userdefault = UserDefaults.standard
    let appStoreID = "6452397746"
    
    var activityIndicatorView = IndicatorViewFactory.build()
    private var cancellables = Set<AnyCancellable>()
    
    private let VM = SettingVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupFunc()
        
        bind()
        
        setupAlarm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDatePickerVC" {
            if let VC = segue.destination as? DatePickerVC {
                VC.VM = VM
            }
        }
    }
    
    private func bind() {
        VM.$alarmTimeChanged
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] time in
                if time != nil {
                    VM.updateNotificationHours(newHour: time!.hour, newMinute: time!.minute)
                    VM.setAlarmHour(to: time!.hour)
                    VM.setAlarmMinute(to: time!.minute)
                    timeClockLabel.text = VM.getAlarmSettedTime()
                }
            }
            .store(in: &cancellables)
    }
}

extension SettingVC {
    private func setupFunc(){
        passwordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLockSettings)))
        languageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLanguageSettings)))
        googleAuthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(googleAuth)))
        rateAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rateApp)))
        buySubscribeBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSubscription)))
        deleteAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAccount)))
    }
    
    @objc private func showLanguageSettings() {
        performSegue(withIdentifier: "showLanguageVC", sender: self)
    }
    
    @objc private func showLockSettings() {
        performSegue(withIdentifier: "showPasswordSettingVC", sender: self)
    }
   
    @objc private func showSubscription() {
        performSegue(withIdentifier: "showSubscriptionVC", sender: self)
    }
    
    @objc private func googleAuth() {
        performSegue(withIdentifier: "showConnectToSNSVC", sender: self)
    }
    
    private func setupUI(){
        buySubscribeBackground.layer.cornerRadius = 10
    }

}

//MARK: ALARM
extension SettingVC {
    @objc 
    private func showTimePicker() {
        performSegue(withIdentifier: "showDatePickerVC", sender: self)
    }
    
    private func setupAlarm() {
        timeClockLabel.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(showTimePicker)))
        if userdefault.string(forKey: "alarmSetting") == nil {checkInitNotificationAuth()}
        else if userdefault.string(forKey: "alarmSetting") == "true" {setupAlarmOnState()}
    }
    
    private func setupAlarmOnState() {
        alarmSwitch.isOn = true
        alarmClockView.isHidden = false
        timeClockLabel.text = VM.getAlarmSettedTime()
    }
    
    @IBAction
    func alarmSwitch(_ sender: Any) {
        if alarmSwitch.isOn {
            // Check notification authorization status
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        print("alarmswitch - is On and authorized")
                        // Update user defaults with the new hour and minute values
                        self.userdefault.set(22, forKey: "alarmTime")
                        self.userdefault.set(00, forKey: "alarmMinute")
                        
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        self.userdefault.set("true", forKey: "alarmSetting")
                        self.alarmClockView.isHidden = false
                        self.timeClockLabel.text = "22:00"
                        self.VM.createNotification()
                        
                    } else {
                        // Notifications not allowed, show alert and turn off switch
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                        self.alarmSwitch.isOn = false
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            userdefault.set("false", forKey: "alarmSetting")
            alarmClockView.isHidden = true
        }
    }
    
    private func checkInitNotificationAuth() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // Update the switch based on notification authorization status
                self.alarmSwitch.isOn = settings.authorizationStatus == .authorized
                if self.alarmSwitch.isOn {
                    self.alarmSwitch.setOn(true, animated: true)
                    self.alarmSwitch.sendActions(for: .valueChanged)
                }
            }
        }
    }
}

//MARK: DELETE ACCOUNT
extension SettingVC {
    @objc private func deleteAccount() {
        let yesaction = UIAlertAction(title: "네".localised, style: .default) { _ in
            let userr = Auth.auth().currentUser
            userr?.delete { error in
                if let error = error {
                    let action = UIAlertAction(
                        title: "네".localised,
                        style: .default,
                        handler: nil)
                    let alert = UIAlertFactory.buildOneAlert(
                        title: "실패했습니다".localised,
                        message: "",
                        okAction: action)

                    self.present(alert, animated: true)
                } else {
                    self.VM.deleteUser(user: userr)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "deleteaccount.title".localised,
            message: "deleteaccount.message".localised,
            okAction: yesaction,
            noAction: UIAlertAction(title: "취소".localised, style: .default))
        
        self.present(alert, animated: true)
    }
}


//MARK: RATE OUR APP SETTINGS
extension SettingVC {
    
    @objc private func rateApp() {
        let yesAction = UIAlertAction(title: "네".localised, 
                                      style: .default) { _ in
            self.activityIndicatorView.startAnimating()
            
            if let appStoreURL = URL(string: "https://apps.apple.com/app/id\(self.appStoreID)?action=write-review") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
            self.activityIndicatorView.stopAnimating()
        }
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "review.title".localised, 
            message: "review.subtitle".localised,
            okAction: yesAction,
            noAction: UIAlertAction(title: "아니요".localised,
                                    style: .default))
       
        self.present(alert, animated: true)
    }
    
}
