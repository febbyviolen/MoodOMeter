//
//  PasswordViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/28.
//

import UIKit
import LocalAuthentication

class PasswordPadVC: UIViewController, UIGestureRecognizerDelegate {
  
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var fourthImg: UIImageView!
    @IBOutlet weak var thirdImg: UIImageView!
    @IBOutlet weak var secondImg: UIImageView!
    @IBOutlet weak var firstImg: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    
    var password = ""
    var authMethod = ""
    
    let userdefaults = UserDefaults.standard
    var VM: PasswordViewSettingVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let NC = self.navigationController?.viewControllerBeforeCurrent() {
            if NC is MainVC {
                if userdefaults.string(forKey: "bioPassword") == "true" { authenticateWithFaceID() }
            } else if NC is PasswordSettingVC {
                closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeScreen)))
                closeButton.isHidden = false
            }
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // === BUTTON ===
    @objc private func closeScreen() {
        VM?.passwordNum = VM?.passwordNum
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func oneButton(_ sender: Any) {
        password += "1"
        passUI()
    }
    
    @IBAction func twoButton(_ sender: Any) {
        password += "2"
        passUI()
    }
    
    @IBAction func threeButton(_ sender: Any) {
        password += "3"
        passUI()
    }
    
    @IBAction func fourthButton(_ sender: Any) {
        password += "4"
        passUI()
    }
    
    @IBAction func fifthButton(_ sender: Any) {
        password += "5"
        passUI()
    }
    
    @IBAction func sixButton(_ sender: Any) {
        password += "6"
        passUI()
    }
    
    @IBAction func sevenButton(_ sender: Any) {
        password += "7"
        passUI()
    }
    
    @IBAction func eightButton(_ sender: Any) {
        password += "8"
        passUI()
    }
    
    @IBAction func nineButton(_ sender: Any) {
        password += "9"
        passUI()
    }
    
    @IBAction func zeroButton(_ sender: Any) {
        password += "0"
        passUI()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        if !password.isEmpty {
            password.removeLast()
            passUI()
        }
    }
}

extension PasswordPadVC {
    private func setupUI() {
        titleLabel.text = "비밀번호 입력해주세요".localised
    }
    
    private func passUI() {
        firstImg.image = UIImage(systemName: "circle")
        secondImg.image = UIImage(systemName: "circle")
        thirdImg.image = UIImage(systemName: "circle")
        fourthImg.image = UIImage(systemName: "circle")
        
        switch password.count {
        case 1:
            DispatchQueue.main.async {
                self.firstImg.image = UIImage(systemName: "circle.fill")
            }
        case 2:
            DispatchQueue.main.async {
                [self.firstImg, self.secondImg].forEach { 
                    $0?.image = UIImage(systemName: "circle.fill")
                }
            }
        case 3:
            DispatchQueue.main.async {
                self.firstImg.image = UIImage(systemName: "circle.fill")
                self.secondImg.image = UIImage(systemName: "circle.fill")
                self.thirdImg.image = UIImage(systemName: "circle.fill")
            }
        case 4:
            DispatchQueue.main.async {
                self.firstImg.image = UIImage(systemName: "circle.fill")
                self.secondImg.image = UIImage(systemName: "circle.fill")
                self.thirdImg.image = UIImage(systemName: "circle.fill")
                self.fourthImg.image = UIImage(systemName: "circle.fill")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.checkPass()
            }
        default:
            DispatchQueue.main.async {
                self.firstImg.image = UIImage(systemName: "circle")
                self.secondImg.image = UIImage(systemName: "circle")
                self.thirdImg.image = UIImage(systemName: "circle")
                self.fourthImg.image = UIImage(systemName: "circle")
            }
        }
        
    }
    
    private func checkPass() {
        if VM != nil{
            VM?.passwordNum = password
            
            navigationController?.popViewController(animated: true)
        } else {
            if password == userdefaults.string(forKey: "password") {
                MainVM.Shared.appIsLocked = false
                navigationController?.popViewController(animated: true)
            } else {
                password = ""
                passUI()
                titleLabel.text = "password.wrong".localised
            }
        }
    }
    
    
    func authenticateWithFaceID() {
        DispatchQueue.main.async {
            let context = LAContext()
            var error: NSError?

            // Check if Face ID is available on the device
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Face ID를 사용하여 인증해주세요".localised

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, 
                                       localizedReason: reason) { success, error in
                    DispatchQueue.main.async {
                        guard success, error == nil else {
                            // Face ID authentication failed
//
                            if self.authMethod == "bio" {
                                self.bioAuthFailAlert()
                            }
                            
                            // if password is also registered as auth
                            if self.userdefaults.string(forKey: "password") != nil {
                                self.passwordFailAlert()
                                
                            } else { //if bioAuth is the only registered auth
                                self.bioAuthFailAlert()
                            }
                            return
                        }
                        
                        // Face ID authentication SUCCESSED
                        if self.authMethod == "bio" {
                            self.userdefaults.set("true", forKey: "bioPassword")
                        } else {
//                            self.delegate.passData(controller: self)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                // Face ID not available on the device or not configured
                // Handle the error accordingly
            }
        }
    }
    
    func bioAuthFailAlert() {
        let tryAgainAction = UIAlertAction(
            title: "faceId.localizedFallbackTitle".localised,
            style: .default
        ) { _ in
            self.authenticateWithFaceID() // Retry Face ID authentication
        }
        let alert = UIAlertFactory.buildOneAlert(
            title: "faceId.localizedAuthenticationFailed".localised,
            message: "faceId.localizedMismatch".localised,
            okAction: tryAgainAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func passwordFailAlert() {
        let tryAgainAction = UIAlertAction(
            title: "faceId.localizedFallbackTitle".localised,
            style: .default
        ) { _ in
            self.authenticateWithFaceID() // Retry Face ID authentication
        }
        
        let cancelAction = UIAlertAction(
            title: "faceId.localizedCancelTitle".localised,
            style: .cancel,
            handler: nil)
        
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "faceId.localizedAuthenticationFailed".localised,
            message: "faceId.localizedMismatch".localised,
            okAction: tryAgainAction,
            noAction: cancelAction)
      
        self.present(alert, animated: true, completion: nil)
    }


}
