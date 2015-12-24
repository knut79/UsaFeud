//
//  HintButton.swift
//  MapFeud
//
//  Created by knut on 12/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class HintButton: UIButton {
    
    var innerView:UILabel!
    var numberOfHints:UILabel!
    var orgFrame:CGRect!
    var hintsLeftOnQuestion:Int = 2
    var hintsLeftOnAccount:Int = 0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        innerView = UILabel(frame: CGRectMake(self.bounds.width * 0.1 ,self.bounds.width * 0.1, self.bounds.width * 0.8,self.bounds.width * 0.8))
        innerView.text = "❕"
        innerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        innerView.textAlignment = NSTextAlignment.Center
        innerView.layer.borderWidth = 2
        innerView.layer.cornerRadius = innerView.bounds.size.width / 2
        innerView.layer.masksToBounds = true
        self.addSubview(innerView)
        
        hintsLeftOnAccount = NSUserDefaults.standardUserDefaults().integerForKey("hintsLeftOnAccount")
        numberOfHints = UILabel(frame: CGRectMake(self.bounds.width * 0.6 ,self.bounds.width * 0.6, self.bounds.width * 0.4,self.bounds.width * 0.4))
        let hintsMiniIcon = hintsLeftOnAccount >= 2 ? "2" : "\(hintsLeftOnAccount)"
        if hintsLeftOnAccount == 0
        {
            numberOfHints.text = "+"
        }
        else
        {
            numberOfHints.text = "\(hintsMiniIcon)"
        }
        
        numberOfHints.backgroundColor = UIColor.blueColor()
        numberOfHints.adjustsFontSizeToFitWidth = true
        numberOfHints.textColor = UIColor.whiteColor()
        numberOfHints.layer.borderColor = UIColor.blueColor().CGColor
        numberOfHints.textAlignment = NSTextAlignment.Center
        numberOfHints.layer.borderWidth = 2
        numberOfHints.layer.cornerRadius = numberOfHints.bounds.size.width / 2
        numberOfHints.layer.masksToBounds = true
        self.addSubview(numberOfHints)
        //innerView.center = CGPointMake(margin + (hintButton.frame.width / 2) , UIScreen.mainScreen().bounds.height * 0.33)
        
    }
    

    func deductHints()
    {
        
        hintsLeftOnAccount = NSUserDefaults.standardUserDefaults().integerForKey("hintsLeftOnAccount")
        hintsLeftOnAccount--
        NSUserDefaults.standardUserDefaults().setInteger(hintsLeftOnAccount, forKey: "hintsLeftOnAccount")
        hintsLeftOnQuestion--
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        datactrl.hintsValue = hintsLeftOnAccount
        datactrl.saveGameData()

        let hintsMiniIcon = hintsLeftOnAccount >= hintsLeftOnQuestion ? "\(hintsLeftOnQuestion)" : "\(hintsLeftOnAccount)"
        if hintsLeftOnAccount <= 0
        {
            numberOfHints.text = "+"
        }
        else
        {
            numberOfHints.text = "\(hintsMiniIcon)"
        }
        
        
        if hintsLeftOnQuestion <= 0
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.hide()
            })
        }
        
        //numberOfHints.text = "\(hintsLeftOnQuestion)"
        
        
    }
    
    func restoreHints()
    {
        hintsLeftOnQuestion = 2
        let hintsMiniIcon = hintsLeftOnAccount >= hintsLeftOnQuestion ? "\(hintsLeftOnQuestion)" : "\(hintsLeftOnAccount)"
        if hintsLeftOnAccount <= 0
        {
            numberOfHints.text = "+"
        }
        else
        {
            numberOfHints.text = "\(hintsMiniIcon)"
        }
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
                self.center = CGPointMake(self.frame.width * -1, self.center.y)
            }
        }
        else
        {
            if hintsLeftOnQuestion > 0
            {
                self.frame = self.orgFrame
            }
        }
    }
}
