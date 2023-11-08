//
//  PlainSegmentedControl.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import UIKit

class PlainSegmentedControl: UISegmentedControl {
    
    override init(items: [Any]?) {
        super.init(items: items)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear

        // Use a clear image for the background and the dividers
        let tintColorImage = UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 32))
        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // Set some default label colors
//        setTitleTextAttributes([.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font.subSize], for: .normal)
        
        setTitleTextAttributes([
            .foregroundColor: UIColor(named: "black")!,
            .underlineStyle: NSUnderlineStyle.double.rawValue,
            .underlineColor: UIColor.gray],
                               for: .selected)
    }
}
