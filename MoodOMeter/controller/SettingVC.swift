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
//import FirebaseAuth
//import FirebaseCore
//import StoreKit

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
    
    private func setupUI(){
        buySubscribeBackground.layer.cornerRadius = 10
        buySubscribeLable.text = "\(String(format: NSLocalizedString("subscription.title", comment: ""))) "
        self.view.addSubview(activityIndicatorView)
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

//MARK: GOOGLE SETTINGS
extension SettingVC {

//    
    @objc private func googleAuth() {
        performSegue(withIdentifier: "showConnectToSNSVC", sender: self)
//
    }
}

//MARK: DELETE ACCOUNT
extension SettingVC {
    @objc private func deleteAccount() {
        let alert = UIAlertController(title: String(format: NSLocalizedString("deleteaccount.title", comment: "")), message: String(format: NSLocalizedString("deleteaccount.message", comment: "")), preferredStyle: .alert)

        let yesaction = UIAlertAction(title: String(format: NSLocalizedString("네", comment: "")), style: .default) { _ in
//            let userr = Auth.auth().currentUser
//            userr?.delete { error in
//                if let error = error {
//                    let alert = UIAlertController(title: String(format: NSLocalizedString("실패했습니다", comment: "")), message: "", preferredStyle: .alert)
//                    let action = UIAlertAction(title: String(format: NSLocalizedString("네", comment: "")), style: .default, handler: nil)
//                    alert.addAction(action)
//
//                    self.present(alert, animated: true)
//                } else {
//                    self.fb.deleteUser(user: userr?.uid ?? "", date: Date())
//                    self.userdefault.set(nil, forKey: "userID")
//                    self.userdefault.set(nil, forKey: "userEmail")
//                    self.userdefault.set("false", forKey: "premiumPass")
//                    self.navigationController?.popViewController(animated: true)
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
        }
        
        let noaction = UIAlertAction(title: String(format: NSLocalizedString("취소", comment: "")), style: .default)

        alert.addAction(noaction)
        alert.addAction(yesaction)
        self.present(alert, animated: true)
    }
}


//MARK: RATE OUR APP SETTINGS
extension SettingVC {
    
    @objc private func rateApp() {
        let alert = UIAlertController(title: String(format: NSLocalizedString("review.title", comment: "")), message: String(format: NSLocalizedString("review.subtitle", comment: "")), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: String(format: NSLocalizedString("네", comment: "")), style: .default) { _ in
            self.activityIndicatorView.startAnimating()
            
            if let appStoreURL = URL(string: "https://apps.apple.com/app/id\(self.appStoreID)?action=write-review") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
            self.activityIndicatorView.stopAnimating()
        }
        
        let noAction = UIAlertAction(title: String(format: NSLocalizedString("아니요", comment: "")), style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
       
        self.present(alert, animated: true)
    }
    
}
