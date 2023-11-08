//
//  InficatorViewFactory.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import UIKit
import NVActivityIndicatorView

struct IndicatorViewFactory {
    static func build() -> NVActivityIndicatorView {
        let activityIndicatorView: NVActivityIndicatorView!
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let type = NVActivityIndicatorType.ballPulse
        let color = UIColor(named: "black")
        let padding: CGFloat = 0
        
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: type, color: color, padding: padding)
        
        activityIndicatorView.center = center
        return activityIndicatorView
    }
}
