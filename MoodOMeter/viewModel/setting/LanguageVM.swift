//
//  LanguageVM.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/9/23.
//

import Foundation
import Combine

class LanguageVM {
    @Published var currLanguage: String?
    
    let userDefault = UserDefaults.standard
    
    init() {
        currLanguage = userDefault.array(forKey: "AppleLanguages")?.first as? String
    }
}
