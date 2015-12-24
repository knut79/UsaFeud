//
//  StatusTimeButton.swift
//  MapFeud
//
//  Created by knut on 28/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class StatusTimeButton:UIButton {
    
    var label:UILabel!
    var timeLabel:UILabel!
    var plusLabel:UILabel!
    let clockEmoji:[String] = ["🕑","🕓","🕗","🕙"]
    var clockEmojiIndex = 0
    
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
        label.text = "Time\(clockEmoji[clockEmojiIndex])  ."
        label.textAlignment = NSTextAlignment.Center
        //label.layer.borderColor = UIColor.lightGrayColor().CGColor
        label.backgroundColor = UIColor.blueColor()
        label.textColor = UIColor.whiteColor()
        label.layer.cornerRadius = 3 //label.bounds.size.width / 2
        label.layer.masksToBounds = true
        self.addSubview(label)
        
        
        
        let timeLabelHeight = label.frame.height * 0.6
        let timeLabelWidth = timeLabelHeight * 1.5
        timeLabel = UILabel(frame: CGRectMake(frame.width - timeLabelWidth, frame.height * 0.5,timeLabelWidth, timeLabelHeight))
        let timeBonus = NSUserDefaults.standardUserDefaults().integerForKey("timeBonus")
        var time:Double = GlobalConstants.timeStart
        for var i = 1 ; i <= timeBonus; i++
        {
            time = time * GlobalConstants.timeBonusMultiplier
        }
        timeLabel.text = "\(Int(time))s"
        timeLabel.textAlignment = NSTextAlignment.Center
        //label.layer.borderColor = UIColor.lightGrayColor().CGColor
        timeLabel.backgroundColor = UIColor.whiteColor()
        timeLabel.textColor = UIColor.blackColor()
        timeLabel.layer.cornerRadius = timeLabelHeight / 2
        timeLabel.layer.borderWidth = 2
        timeLabel.layer.borderColor = UIColor.blueColor().CGColor
        timeLabel.layer.masksToBounds = true
        self.addSubview(timeLabel)
        
        plusLabel = UILabel(frame: CGRectMake(frame.width - timeLabelHeight, timeLabelHeight * 0.33,timeLabelHeight, timeLabelHeight))
        plusLabel.backgroundColor = UIColor.clearColor()
        plusLabel.textColor = UIColor.whiteColor()
        plusLabel.text = "+"
        self.addSubview(plusLabel)
        
        
    }
    
    func sTime(timeBonus:Int)
    {
        clockEmojiIndex = (clockEmojiIndex + 1) % clockEmoji.count
        
        label.text = "Time\(clockEmoji[clockEmojiIndex])  ."
        var time:Double = GlobalConstants.timeStart
        for var i = 1 ; i <= timeBonus; i++
        {
            time = time * GlobalConstants.timeBonusMultiplier
        }
        timeLabel.text = "\(Int(time))s"
    }
}
