//
//  ConnectGoogleAccountViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/08.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import NVActivityIndicatorView
import AuthenticationServices
import Combine
import CombineCocoa

class ConnectToSNSVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    
    @IBOutlet weak var unconnectButton: UIButton!
    @IBOutlet weak var appleStartConnectingButton: UIButton!
    @IBOutlet weak var startConnectingButton: UIButton!
    @IBOutlet weak var secondRuleButton: UIButton!
    @IBOutlet weak var firstRuleButton: UIButton!
    
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    
//    let font = Font()
    let userDefault = UserDefaults.standard
    private let VM = ConnectToSNSVM()
    private var cancellables = Set<AnyCancellable>()
//    let fb = Firebase()
    
    var activityIndicatorView = IndicatorViewFactory.build()
    var firstRule = false
    var secondRule = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bind()
    }
    
    private func bind(){
        VM.$userEmail
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] email in
                if email != nil {
                    stackView1.isHidden = true
                    stackView2.isHidden = true
                    stackView3.isHidden = true
                    label1.text = "connection.message".localised
                    label1.textAlignment = .center
                    
                    unconnectButton.layer.cornerRadius = 10
                    unconnectButton.isHidden = false
                } else {
                    setupUI()
                }
            }
            .store(in: &cancellables)
    }

    
    @IBAction func firstRuleButton(_ sender: Any) {
        firstRule = !firstRule
        firstRuleButton.setImage(firstRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        if firstRule && secondRule {
            buttonActivated()
        } else {
            buttonDisactivate()
        }
    }
    
    @IBAction func secondRuleButton(_ sender: Any) {
        secondRule = !secondRule
        secondRuleButton.setImage(secondRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        
        if firstRule && secondRule {
            buttonActivated()
        } else {
            buttonDisactivate()
        }
    }
    
    private func buttonActivated() {
        startConnectingButton.isEnabled = true
        appleStartConnectingButton.isEnabled = true
        appleStartConnectingButton.layer.opacity = 1
        startConnectingButton.layer.opacity = 1
    }
    
    private func buttonDisactivate() {
        startConnectingButton.isEnabled = false
        appleStartConnectingButton.isEnabled = false
        appleStartConnectingButton.layer.opacity = 0.5
        startConnectingButton.layer.opacity = 0.5
    }
    
    @IBAction func unconnect(_ sender: Any) {
        //add alert
        VM.setUserEmail(to: nil)
        userDefault.set(nil, forKey: "userID")
        self.userDefault.set("false", forKey: "premiumPass")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func application(_ app: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    @IBAction func googleStartConnectingButton(_ sender: Any) {
        if firstRule && secondRule {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            activityIndicatorView.startAnimating()
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                guard error == nil else {
                    // ...
                    print("Google sign-in error: \(error!.localizedDescription)")
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    print("Google connect - error to get user and ID token")
                    return
                }
                
                //alert
                VM.checkIfGoogleAccountExists(idToken: idToken, completion: { str, uid in
                    self.activityIndicatorView.stopAnimating()
                    if str != "false" {
                        // Create a new UIAlertController
                        self.userExistedAlert(uid: uid, userEmail: user.profile?.email)
                        
                    } else {
                        //if there is no google account exists
                        self.VM.transferUserData(merge: false, uid: uid, userEmail: user.profile?.email) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func appleStartConnectingButton(_ sender: Any) {
        if firstRule && secondRule {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.email, .fullName]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

//MARK: APPLE LOGIN
extension ConnectToSNSVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //if failed
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //if success
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            //get credentials data here
            
            self.activityIndicatorView.startAnimating()
            guard let appleIDToken = credentials.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let nonce = userDefault.string(forKey: "userID")!
            
            let userCredential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: credentials.fullName)
            
            VM.isRegisteredUser(credential: userCredential) { str, uid in
                self.activityIndicatorView.stopAnimating()
                if str != "false" {
                    // Create a new UIAlertController
                    self.userExistedAlert(uid: uid, userEmail: credentials.email ?? credentials.fullName?.givenName ?? "apple")
                    
                } else {
                    //if there is no google account exists
                    self.VM.transferUserData(merge: false, uid: uid, userEmail: credentials.email ?? credentials.fullName?.givenName ?? "apple") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            break
        default:
            break
        }
    }
    
  
}

extension ConnectToSNSVC: ASAuthorizationControllerPresentationContextProviding {
    
    //set which kind of window you want the device to pop
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension ConnectToSNSVC {
    private func userExistedAlert(uid: String, userEmail: String?){
        let yesAction = UIAlertAction(title: "네".localised, style: .default) { _ in
            self.VM.transferUserData(merge: true, uid: uid, userEmail: userEmail) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { _ in
            self.VM.transferUserData(merge: false, uid: uid, userEmail: userEmail) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "merge_data_message".localised,
            message: "",
            okAction: yesAction,
            noAction: noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupUI() {
        stackView1.layer.backgroundColor = UIColor.white.cgColor
        stackView1.addShadow(offset: CGSize(width: 0, height: 0),
                             color: UIColor(named: "black")!,
                             radius: 4,
                             opacity: 0.1)
        stackView1.layer.cornerRadius = 16
        stackView1.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        startConnectingButton.layer.cornerRadius = 10
        startConnectingButton.isEnabled = false
        startConnectingButton.layer.opacity = 0.5
        
        appleStartConnectingButton.layer.cornerRadius = 10
        appleStartConnectingButton.isEnabled = false
        appleStartConnectingButton.layer.opacity = 0.5
        
        
        unconnectButton.isHidden = true
        let str = NSAttributedString(string: "connectAccount.firstRule".localised, attributes: [
            .font: UIFont.systemFont(ofSize: 12)
        ])
        let str2 = NSAttributedString(string: "connectAccount.secondRule".localised, attributes: [
            .font: UIFont.systemFont(ofSize: 12)
        ])
        
        firstRuleButton.setAttributedTitle(str, for: .normal)
        secondRuleButton.setAttributedTitle(str, for: .normal)
        self.view.addSubview(activityIndicatorView)
    }
}
