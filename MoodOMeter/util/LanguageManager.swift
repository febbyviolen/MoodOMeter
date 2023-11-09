//
//  LanguageManager.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/03.
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()

    func setAppLanguage(_ languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
