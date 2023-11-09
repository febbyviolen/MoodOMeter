//
//  ConnectToSNSVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/9/23.
//

import Foundation
import Combine

class ConnectToSNSVM {
    @Published var userEmail: String?
    
    private var userDefault = UserDefaults.standard
    
    init(){
        userEmail = userDefault.string(forKey: "userEmail")
    }
    
    func getUserEmail() -> String? {
        return userDefault.string(forKey: "userEmail")
    }
    
    func setUserEmail(to email: String?){
        userDefault.set(email, forKey: "userEmail")
    }
}
