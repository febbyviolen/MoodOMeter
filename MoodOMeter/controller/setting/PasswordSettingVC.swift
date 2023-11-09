//
//  PasswordSettingsViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/29.
//

import UIKit
import LocalAuthentication
import Combine
import CombineCocoa

class PasswordSettingVC: UIViewController {
    
    @IBOutlet weak var changePassView: UIView!
    @IBOutlet weak var PasswordView: UIView!
    @IBOutlet weak var BiometricView: UIView!
    @IBOutlet weak var bioSwitch: UISwitch!
    @IBOutlet weak var passSwitch: UISwitch!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var changePassLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    private let userDefault = UserDefaults.standard
    private var cancellable = Set<AnyCancellable>()
    let VM = PasswordViewSettingVM()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        bind()
        changePassView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPasswordPad)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPasswordPadVC" {
            if let VC = segue.destination as? PasswordPadVC {
                VC.VM = VM
            }
        }
    }
    
    private func bind() {
        VM.$passwordNum
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] pass in
                print(pass)
                changePassView.isHidden = pass == nil ? true : false
                passSwitch.isOn = pass == nil ? false : true
                VM.setPasswordNum(to: pass)
            }
            .store(in: &cancellable)
    }
    
    @objc private func showPasswordPad(){
        performSegue(withIdentifier: "showPasswordPadVC", sender: self)
    }
    
    @IBAction func passLabel(_ sender: Any) {
        if passSwitch.isOn {
            VM.onChangingPassword = false
            performSegue(withIdentifier: "showPasswordPadVC", sender: self)
        } else {
            VM.passwordNum = nil
        }
    }
    
    @IBAction func bioLabel(_ sender: Any) {
        if bioSwitch.isOn{
            authenticateWithFaceID()
        } else {
            VM.setBiometricValid(to: "false")
        }
    }
    
}

extension PasswordSettingVC {
    private func setupUI() {
        [PasswordView, BiometricView, changePassView].forEach({
            $0?.addShadow(offset: CGSize(width: 0, height: 0),
                                   color: UIColor(named: "black")!,
                                   radius: 1,
                                   opacity: 0.2)
            $0?.addCornerRadius(radius: 16)
            $0?.backgroundColor = .white
        })
        
        if VM.getPasswordValid() {
            changePassView.isHidden = false
            passSwitch.setOn(true, animated: false)
        }
        if VM.getBiometricValid() {
            bioSwitch.setOn(true, animated: false)
        }
    }
    
    func authenticateWithFaceID() {
        DispatchQueue.main.async {
            let context = LAContext()
            var error: NSError?

            // Check if Face ID is available on the device
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = String(format: NSLocalizedString("Face ID를 사용하여 인증해주세요", comment: ""))

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                    DispatchQueue.main.async {
                        guard success, error == nil else {
                            // Face ID authentication failed
                            let alertController = UIAlertController(
                                title: String(format: NSLocalizedString("faceId.localizedAuthenticationFailed", comment: "")), message: "",
                                preferredStyle: .alert)
                            
                            let cancelAction = UIAlertAction(
                                title: String(format: NSLocalizedString("네", comment: "")),
                                style: .default
                            ) { _ in
                                self.bioSwitch.isOn = false
                            }
                            
                            alertController.addAction(cancelAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        //success
                        self.VM.setBiometricValid(to: "true")
                    }
                }
            } else {
                // Face ID not available on the device or not configured
                // Handle the error accordingly
                let alertController = UIAlertController(
                    title: String(format: NSLocalizedString("biometricAuthentication.notAvailable", comment: "")),
                    message: "",
                    preferredStyle: .alert)
               
                let cancelAction = UIAlertAction(
                    title: String(format: NSLocalizedString("네", comment: "")),
                    style: .default,
                    handler: { _ in
                        self.bioSwitch.setOn(false, animated: true)
                        self.VM.setBiometricValid(to: "false")
                    })
                cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
}
