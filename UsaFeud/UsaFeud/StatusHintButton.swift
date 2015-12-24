//
//  StatusHintButton.swift
//  MapFeud
//
//  Created by knut on 28/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class StatusHintButton:UIButton {
    
    var label:UILabel!
    var hintsLabel:UILabel!
    var plusLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        let margin = frame.height * 0.1
        label = UILabel(frame: CGRectMake(margin, margin, frame.width - (margin * 2), frame.height * 0.8))
        label.font = UIFont.boldSystemFontOfSize(20)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Hints❕ "
        label.textAlignment = NSTextAlignment.Center
        //label.layer.borderColor = UIColor.lightGrayColor().CGColor
        label.backgroundColor = UIColor.blueColor()
        label.textColor = UIColor.whiteColor()
        label.layer.cornerRadius = 3 //label.bounds.size.width / 2
        label.layer.masksToBounds = true
        self.addSubview(label)
        
        let hints = NSUserDefaults.standardUserDefaults().integerForKey("hintsLeftOnAccount")
        let hintsLabelSide = label.frame.height * 0.6
        hintsLabel = UILabel(frame: CGRectMake(frame.width - hintsLabelSide, frame.height * 0.5,hintsLabelSide, hintsLabelSide))
        hintsLabel.text = "\(hints)"
        hintsLabel.adjustsFontSizeToFitWidth = true
        hintsLabel.textAlignment = NSTextAlignment.Center
        //label.layer.borderColor = UIColor.lightGrayColor().CGColor
        hintsLabel.backgroundColor = UIColor.whiteColor()
        hintsLabel.textColor = UIColor.blackColor()
        hintsLabel.layer.cornerRadius = hintsLabelSide / 2
        hintsLabel.layer.borderWidth = 2
        hintsLabel.layer.borderColor = UIColor.blueColor().CGColor
        hintsLabel.layer.masksToBounds = true
        self.addSubview(hintsLabel)
        
        plusLabel = UILabel(frame: CGRectMake(frame.width - hintsLabelSide, hintsLabelSide * 0.33,hintsLabelSide, hintsLabelSide))
        plusLabel.backgroundColor = UIColor.clearColor()
        plusLabel.textColor = UIColor.whiteColor()
        plusLabel.text = "+"
        self.addSubview(plusLabel)
        
    }
    
    func sHints(hints:Int)
    {
        hintsLabel.text = "\(hints)"
    }
}