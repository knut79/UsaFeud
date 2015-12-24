//
//  HintsView.swift
//  MapFeud
//
//  Created by knut on 26/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

protocol StatsViewProtocol
{
    func requestBuyHints()
    func requestBuyTime()
}

class StatsView: UIView {
    
    
    //var hintsLeftText:UILabel!
    var hintsButton:StatusHintButton!
    var timeButton:StatusTimeButton!
    var distanceButton:StatusDistanceButton!
    
    var versionText:UILabel!
    let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
    var delegate:StatsViewProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        //self.layer.borderColor = UIColor.grayColor().CGColor
        //self.layer.borderWidth = 2
        self.layer.cornerRadius = 1
        self.layer.masksToBounds = true
        
        let labelWidth = self.bounds.width * 0.38
        
        hintsButton = StatusHintButton(frame: CGRectMake(0, 0, labelWidth, self.bounds.height))
        hintsButton.addTarget(self, action: "addHints", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(hintsButton)
        
        timeButton = StatusTimeButton(frame: CGRectMake(hintsButton.frame.maxX, 0, labelWidth, self.bounds.height))
        timeButton.addTarget(self, action: "addTime", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(timeButton)

        distanceButton = StatusDistanceButton(frame: CGRectMake(timeButton.frame.maxX, 0, self.bounds.width - (labelWidth * 2), self.bounds.height))
        distanceButton.addTarget(self, action: "switchDistance", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(distanceButton)
        
    }
    
    func switchDistance()
    {
        distanceButton.swapDistance()
    }
    
    func addHints()
    {
        delegate?.requestBuyHints()

    }
    
    func addTime()
    {
        delegate?.requestBuyTime()
    }

}