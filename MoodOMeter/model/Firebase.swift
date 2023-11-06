//
//  Database.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/18.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class Firebase {
    static let Shared = Firebase()
    
    var calendar = Calendar.current
    let userDefault = UserDefaults.standard
    
    var userID: String {
        return userDefault.string(forKey: "userID") ?? ""
    }
    
    var userDocRef: DocumentReference {
        return Firestore.firestore().collection("users").document(userID)
    }
    
    //MARK: USERS INFO
    func anonymSign(completion: @escaping () -> Void) {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print("anonymSign - in error: \(error)")
            } else {
                guard let user = authResult?.user else {
                    // User object is nil
                    print("anonymSign - user is not valid")
                    return
                }
                let userID = user.uid
                self.userDefault.set(userID, forKey: "userID")
                completion()
            }
        }
    }
    
    func deleteUser(user: String, date: Date){
        let docRef = userDocRef
        
        let data : [String: Any] = [
            "deleted" : "True", 
            "date" : date.description
        ]
        
        docRef.setData(data, merge: false) { error in
            if let error = error {
                print("deleteUser - cannot delete user: \(error)")
            } else {
                print("deleteUser - deleting user is successed")
            }
        }
    }
    
    //MARK: EDITING DIARY DATA
    //get data for mainVC
    func getDiaryData(date: Date) -> AnyPublisher<([String], String, String, String), Error> {
        let year = date.toString(format: "yyyy")
        let docRef = userDocRef.collection(year)
        
        return Future { promise in
            docRef.getDocuments { document, err in
                if let error = err {
                    print("getDiaryData - error getting data: \(error)")
                    promise(.failure(error))
                } else {
                    for document in document!.documents {
                        print("getDiaryData - successed getting data")
                        //                    print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let ID = document.documentID // (ex: 2023.06.01)
                        if let sticker = data["sticker"] as? [String],
                           let story = data["story"] as? String,
                           let date = data["date"] as? String {
                            promise(.success((sticker, story, date, ID)))
                        }
                        
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addDiary(date: Date, sticker: [String], story: String) {
        let year = date.toString(format: "yyyy")
        let month = date.toString(format: "MM")
        let day = date.toString(format: "dd")
        
        let docRef = userDocRef.collection("\(year)").document("\(year).\(month).\(day)")
        
        let data : [String: Any] = [
            "sticker" : sticker,
            "story" : story,
            "date" : "\(year).\(month).\(day)"
        ]
        
        docRef.setData(data, merge: true) { error in
            if let error = error {
                print("addDiary - error adding data: \(error)")
            } else {
                print("addDiary - success adding data")
            }
        }
    }
    
    func deleteDiary(date: Date) {
        let year = date.toString(format: "yyyy")
        let month = date.toString(format: "MM")
        let day = date.toString(format: "dd")
        
        let docRef = userDocRef
            .collection("\(year)")
            .document("\(year).\(month).\(day)")
        
        docRef.delete() { error in
            if let error = error {
                print("deleteDiary - error deleting data: \(error)")
            } else {
                print("deleteDiary - success deleting data ")
            }
        }
    }
    
    //MARK: TRANSFERING DATA
    //get user data
    func transferUserData(idToken: String, merge: Bool, completion: @escaping () -> Void){
        
        var date = Date()
        let year = date.toString(format: "yyyy")
       
        for i in 0...100 {
            var dateComponents = DateComponents()
            dateComponents.year = -i
            
            if let year = calendar.date(byAdding: dateComponents, to: date) {
                date = year
            }
            
            let docRef = Firestore
                .firestore()
                .collection("users")
                .document(userID)
                .collection(year)
            
            let destDocRef = Firestore
                .firestore()
                .collection("users")
                .document(idToken)
                .collection(year)
            
            docRef.getDocuments { document, err in
                if let error = err {
                    print("transferUserData - Error user's getting documents: \(error)")
                    completion()
                } else {
                    for document in document!.documents {
                        print("transferUserData - success getting document")
    //                    print("\(document.documentID) => \(document.data())")
                        
                        let data = document.data()
                        let ID = document.documentID // (ex: 2023.06.01
                        if let sticker = data["sticker"] as? [String], 
                            let story = data["story"] as? String,
                            let date = data["date"] as? String {
                            
                            let data : [String: Any] = [
                                "sticker" : sticker,
                                "story" : story,
                                "date" : date
                            ]
                            
                            destDocRef.document(date).setData(data, merge: merge) { error in
                                if let error = error {
                                    print("transferUserData - Error transfering documents: \(error)")
                                    completion()
                                } else {
                                    print("transferUserData - success transfering documents")
                                }
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        let docRef = userDocRef.collection("subscription")
        let destDocRef = Firestore
            .firestore()
            .collection("users")
            .document(idToken)
            .collection("subscription")
        
        docRef.getDocuments { document, err in
            if let error = err {
                print("transferUserData - Error user's getting subscription documents: \(error)")
                completion()
            } else {
                for document in document!.documents {
                    print("transferUserData - success getting subscription document")
//                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    if let premiumPass = data["premiumPass"] as? String, 
                        let ID = data["premiumPassID"] {
                        
                        let data : [String: Any] = [
                            "premiumPass" : premiumPass,
                            "premiumPassID" : ID
                        ]
                        
                        destDocRef
                            .document("subscriptionInfo")
                            .setData(data, merge: true) { error in
                            if let error = error {
                                print("transferUserData - Error transfering subscription documents: \(error)")
                                completion()
                            } else {
                                print("transferUserData - success transfering subscription documents")
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        
        completion()
    }
    
    
    //MARK: SUBSCRIPTION
    func getSubscriptionInfo() {
        let docRef = userDocRef.collection("subscription")
        
        docRef.getDocuments { document, err in
            if let error = err {
                print("getSubcriptionInfo - error getting Subscription Info : \(error)")
                self.userDefault.set("false", forKey: "premiumPass")
            } else {
                for document in document!.documents {
                    print("getSubcriptionInfo - successed getting Subscription Info")
                    let data = document.data()
                    if let premiumPass = data["premiumPass"] as? String {
                        if premiumPass == "true" {
                            self.userDefault.set("true", forKey: "premiumPass")
                        } else {
                            self.userDefault.set("false", forKey: "premiumPass")
                        }
                    }
                    
                }
            }
        }
    }
    
    func saveSubscriptionInfo(premiumID: String, completion: @escaping () -> Void) {
        let docRef = userDocRef
            .collection("subscription")
            .document("subsciptionInfo")
        
        let data : [String: Any] = [
            "premiumPass" : "true",
            "premiumPassID" : "\(premiumID)",
            "date" : Date().description
        ]
        
        docRef.setData(data, merge: false) { error in
            if let error = error {
                print("saveSubscriptionInfo - error saving Subscription Info : \(error)")
                completion()
            } else {
                print("saveSubscriptionInfo - successed saving Subscription Info \(premiumID)")
                completion()
            }
        }
    }
}
