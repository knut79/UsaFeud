//
//  DistanceView.swift
//  MapFeud
//
//  Created by knut on 18/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit


class DistanceView: UIView {
    
    var distance:Int = 0
    var distanceLabel:UILabel!
    var orgFrame:CGRect!
    var usingKm:Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, usingKm:Bool) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()
        self.usingKm = usingKm
        distanceLabel = UILabel(frame: CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        distanceLabel.adjustsFontSizeToFitWidth = true
        
        distanceLabel.text = usingKm ? "0 km" : "0 miles"
        distanceLabel.textAlignment = NSTextAlignment.Center
        distanceLabel.font = UIFont.boldSystemFontOfSize(24)
        distanceLabel.textColor = UIColor.whiteColor()
        self.addSubview(distanceLabel)

    }

    func addDistance(dist:Int)
    {
        self.distance = self.distance + dist
        
        var distanceInRightMeasure:String =  usingKm ? "\(distance)" : "\(Int(CGFloat(distance) * 0.621371))"
        distanceInRightMeasure = distanceInRightMeasure.characters.count > 6 ? distanceInRightMeasure.insertC(" ", ind: distanceInRightMeasure.characters.count - 6)  : distanceInRightMeasure
        distanceInRightMeasure = distanceInRightMeasure.characters.count > 3 ? distanceInRightMeasure.insertC(" ", ind: distanceInRightMeasure.characters.count - 3)  : distanceInRightMeasure
        let distanceText = usingKm ? "\(distanceInRightMeasure) km" : "\(distanceInRightMeasure) miles"
        self.distanceLabel.text = distanceText
        
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        pulseAnimation.duration = 0.3
        pulseAnimation.toValue = NSNumber(float: 0.3)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = 5
        pulseAnimation.delegate = self
        distanceLabel.layer.addAnimation(pulseAnimation, forKey: "whatever")
        
    }
    


    func isVisible() -> Bool
    {
        return self.frame == orgFrame
    }
    
    func hide(hide:Bool = true)
    {
        if hide
        {
            if isVisible()
            {
                self.center = CGPointMake(self.center.x, UIScreen.mainScreen().bounds.maxY + self.frame.height)
            }
        }
        else
        {
            self.frame = self.orgFrame
        }
    }
    
}

extension String {
    func insertC(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}

