//
//  GoogleMobsFactory.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/21/23.
//

import Foundation
import GoogleMobileAds
import UIKit

struct GoogleMobsFactory {
    static func build(at view: UIViewController) {
        var banner: GADBannerView
        banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: view.view.frame.size.width, height: 50)))
        
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.view.addSubview(banner)
        view.view.addConstraints(
            [NSLayoutConstraint(item: banner,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.view,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: banner,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
        banner.adUnitID = "ca-app-pub-2267001621089435/8329415847"
        banner.backgroundColor = .secondarySystemBackground
        banner.rootViewController = view
        
        banner.load(GADRequest())
    }
    
    
}
