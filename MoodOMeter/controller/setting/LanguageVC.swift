//
//  LanguageViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/02.
//

import UIKit
import Combine

class LanguageVC: UIViewController {
    
    @IBOutlet weak var bahasaButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var KoreanButton: UIButton!
    @IBOutlet weak var bahasaLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreaLabel: UILabel!
    @IBOutlet weak var koreaContainer: UIView!
    @IBOutlet weak var englishContainer: UIView!
    @IBOutlet weak var bahasaContainer: UIView!
    
    private let VM = LanguageVM()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        bind()
        [koreaContainer, englishContainer, bahasaContainer].forEach {
            $0?.addShadow(offset: CGSize(width: 0, height: 0),
                                   color: UIColor(named: "black")!,
                                   radius: 1,
                                   opacity: 0.2)
            $0?.addCornerRadius(radius: 16)
            $0?.backgroundColor = UIColor(named: "whiteDefault")
        }
        
    }
    
    private func bind() {
        VM.$currLanguage
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] language in
                setupUI(language)
                if language != nil {
                    LanguageManager.shared.setAppLanguage(language!)}
            }
            .store(in: &cancellables)
    }
    

    @IBAction func koreaButton(_ sender: Any) {
        
        if VM.currLanguage != "kor"{
            VM.currLanguage = "kor" // Replace with the language code for the selected language
            showNeedToRestartAppAlert()
        }
    }

    
    @IBAction func englishButton(_ sender: Any) {
        if VM.currLanguage != "en"{
            VM.currLanguage = "en" // Replace with the language code for the selected language
            showNeedToRestartAppAlert()
        }
    }
    
    @IBAction func bahasaButton(_ sender: Any) {
        if VM.currLanguage != "id"{
            VM.currLanguage = "id" // Replace with the language code for the selected language
            showNeedToRestartAppAlert()
        }
    }
    
    private func setupUI(_ languageCode: String?) {
        self.KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        self.englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        self.bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        
        switch languageCode {
        case _ where languageCode!.contains("ko") :
            KoreanButton.setImage(
                UIImage(systemName: "circle.inset.filled"),
                for: .normal)
        case _ where languageCode!.contains("en"):
            englishButton.setImage(
                UIImage(systemName: "circle.inset.filled"),
                for: .normal)
        case _ where languageCode!.contains("id"):
            bahasaButton.setImage(
                UIImage(systemName: "circle.inset.filled"),
                for: .normal)
        default :
            self.KoreanButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            self.englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            self.bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        }
    }
    
    private func showNeedToRestartAppAlert() {
        let okAction = UIAlertAction(
            title: "language.restart".localised,
            style: .default, handler: { _ in
            self.restartApplication()
        })
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "language.restartInstruction".localised,
            message: "language.restartMessage".localised,
            okAction: okAction,
            noAction: UIAlertAction(title: "language.later".localised,
                                    style: .default,
                                    handler: nil))
        
        self.present(alert, animated: true)
    }
    
    private func restartApplication() {
            guard let appDelegate = UIApplication.shared.delegate else {
                return
            }

            if let sceneDelegate = appDelegate.window??.windowScene?.delegate {
                // For iOS 13 and later
                if let sceneSession = sceneDelegate as? UISceneSession {
                    UIApplication.shared.requestSceneSessionDestruction(sceneSession, options: nil, errorHandler: nil)
                }
            } else {
                // For earlier iOS versions
                exit(0)
            }
        }
    
}
