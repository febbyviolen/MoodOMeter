//
//  ConnectToSNSVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/9/23.
//

import Foundation
import Combine
import GoogleSignIn
import FirebaseAuth

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
    
    func getUserID() -> String? {
        return userDefault.string(forKey: "userID")
    }
    
    func setUserID(to: String?) {
        userDefault.set(to, forKey: "userID")
    }
    
    func transferUserData(merge: Bool, uid: String, userEmail: String?, completion: @escaping () -> Void) {
        Firebase.Shared.transferUserData(idToken: uid, merge: merge) {
            Firebase.Shared.deleteUser(user: self.getUserID()!, date: Date())
            self.setUserID(to: uid)
            self.setUserEmail(to: userEmail)
            completion()
        }
    }
    
    //GOOGLE
    func checkIfGoogleAccountExists(idToken: String, completion: @escaping (String, String) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: "")
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase authentication error: \(error.localizedDescription)")
                completion("false", "")
                return
            }
            
            // Successfully signed in with Google
            if authResult?.additionalUserInfo?.isNewUser == true {
                // Google account is not registered with Firebase
                print("Google account - not registered with Firebase")
                completion("false", authResult!.user.uid)
            } else {
                // Google account is already registered with Firebase
                print("Google account - already registered with Firebase")
                completion("true", authResult!.user.uid)
            }
        }
    }
    
    //APPLE
    func isRegisteredUser(credential: OAuthCredential, completion: @escaping (String, String) -> Void) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase authentication error: \(error.localizedDescription)")
                completion("false", "" )
                return
            }
            
            // Successfully signed in with Apple
            if authResult?.additionalUserInfo?.isNewUser == true {
                completion("false", authResult!.user.uid)
            } else {
                completion("true", authResult!.user.uid)
            }
        }
    }
}
