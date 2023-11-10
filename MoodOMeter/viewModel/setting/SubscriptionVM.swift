//
//  SubscriptionVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/9/23.
//

import Foundation
import Combine
import StoreKit

class SubscriptionVM {
    @Published var purchased: String?
    let productsIDsToRestore = "moody.premiumPass"
    
    let userDefault = UserDefaults.standard
    var model : SKProduct!
    
    init() {
        purchased = userDefault.string(forKey: "premiumPass")
    }
    
    func setPremiumPass(to bool: String) {
        userDefault.set(bool, forKey: "premiumPass")
    }
    
    func preventInterupttedReceipt() {
        self.userDefault.set("true", forKey: "needSendToServer")
        if let url = Bundle.main.appStoreReceiptURL,
           let data = try? Data(contentsOf: url) {
            let receiptBase64 = data.base64EncodedString()
//                         Send to server
            Firebase.Shared.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                self.userDefault.set("false", forKey: "needSendToServer")
            })
        }
    }
}
