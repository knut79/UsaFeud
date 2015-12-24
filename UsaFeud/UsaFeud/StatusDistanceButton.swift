//
//  StatusDistanceButton.swift
//  MapFeud
//
//  Created by knut on 28/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class StatusDistanceButton:UIButton {
    
    var label:UILabel!
    var distanceLabel:UILabel!
    var swapLabel:UILabel!
    var km:Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        km = NSUserDefaults.standardUserDefaults().boolForKey("useKm")
        let margin = frame.height * 0.1
        distanceLabel = UILabel(frame: CGRectMake(margin, margin, frame.width - (margin * 2), frame.height * 0.8))
        distanceLabel.text = km ? "Km" : "Miles"
        distanceLabel.font = UIFont.boldSystemFontOfSize(20)
        distanceLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.textAlignment = NSTextAlignment.Center
        distanceLabel.backgroundColor = UIColor.blueColor()
        distanceLabel.textColor = UIColor.whiteColor()
        distanceLabel.layer.cornerRadius = 3 //label.bounds.size.width / 2
        distanceLabel.layer.masksToBounds = true
        self.addSubview(distanceLabel)

        let swapLabelSide = frame.height * 0.5
        swapLabel = UILabel(frame: CGRectMake(frame.width - swapLabelSide, frame.height * 0.6,swapLabelSide , swapLabelSide))
        swapLabel.text = "🔁"
        swapLabel.textAlignment = NSTextAlignment.Center
        swapLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(swapLabel)

    }
    
    func swapDistance()
    {
        let slideInFromRightTransition = CATransition()
        self.distanceLabel.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromTopTransition")
        slideInFromRightTransition.delegate = self
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 0.5
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        km = !km
        distanceLabel.text = km ? "Km" : "Miles"
        NSUserDefaults.standardUserDefaults().setBool(km, forKey: "useKm")
    }
}
