//
//  PasswordViewSettingVm.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/9/23.
//

import Foundation
import UIKit

class PasswordViewSettingVM {
    
    @Published var passwordNum: String? = nil
    
    private let userdefault = UserDefaults.standard
    var onChangingPassword = false
    
    init() {
        passwordNum = getPasswordNum()
    }
    
    func getPasswordValid() -> Bool {
        return userdefault.string(forKey: "password") != nil && userdefault.string(forKey: "password")!.count == 4
    }
    
    func getPasswordNum() -> String? {
        return userdefault.string(forKey: "password")
    }
    
    func setPasswordNum(to num: String?) {
        userdefault.set(num, forKey: "password")
    }
    
    func getBiometricValid() -> Bool {
        return userdefault.string(forKey: "bioPassword") == "true"
    }
    
    func setBiometricValid(to bool: String) {
        userdefault.set(bool, forKey: "bioPassword")
    }
}
