//
//  Mood.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import Foundation

enum Mood: CaseIterable{
    case smile, happy, cry, teary, trembled, crisis, flat, annoyed, dumb, frustated, sick, mesmerized, sigh, sleepy, silly, stunned, yummy
    
    var imgName: String {
        switch self {
        case .smile:
            return "smile"
        case .happy:
            return "happy"
        case .cry:
            return "cry"
        case .teary:
            return "teary"
        case .trembled:
            return "trembled"
        case .crisis:
            return "crisis"
        case .flat:
            return "flat"
        case .annoyed:
            return "annoyed"
        case .dumb:
            return "dumb"
        case .frustated:
            return "frustated"
        case .sick:
            return "sick"
        case .mesmerized:
            return "mesmerized"
        case .sigh:
            return "sigh"
        case .sleepy:
            return "sleepy"
        case .silly:
            return "silly"
        case .stunned:
            return "stunned"
        case .yummy:
            return "yummy"
        }
    }
}

enum mainDaily: CaseIterable {
    case sunny, cloudy, rain, music, cleaning, work, paint, plant, birthday, cafe, camera, coding, gaming, drink, eat, drive, salon, holiday, knitting, medicine, netflix, youtube, popcorn
    
    var imgName: String {
        switch self {
        case .sunny:
            return "sunny"
        case .cloudy:
            return "cloudy"
        case .rain:
            return "rain"
        case .music:
            return "music"
        case .netflix:
            return "netflix"
        case .youtube:
            return "youtube"
        case .cleaning:
            return "cleaning"
        case .work:
            return "work"
        case .paint:
            return "paint"
        case .plant:
            return "plant"
        case .birthday:
            return "birthday"
        case .cafe:
            return "cafe"
        case .camera:
            return "camera"
        case .coding:
            return "coding"
        case .gaming:
            return "gaming"
        case .drink:
            return "drink"
        case .eat:
            return "eat"
        case .drive:
            return "drive"
        case .salon:
            return "salon"
        case .holiday:
            return "holiday"
        case .knitting:
            return "knitting"
        case .medicine:
            return "medicine"
        case .popcorn:
            return "popcorn"
        }
    }
}
