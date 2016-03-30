//
//  QuestionView.swift
//  MapFeud
//
//  Created by knut on 12/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class AnswerView: UIView {
    
    
    var answerText:UILabel!
    var infoText:UILabel!
    var infoButton:UILabel!
    var informationIcon:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()

        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AnswerView.tapAnswer(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(singleTapGestureRecognizer)

        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AnswerView.tapAnswer(_:)))
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        swipeUpGestureRecognizer.enabled = true
        swipeUpGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(swipeUpGestureRecognizer)
        
        
        
        infoText = UILabel(frame: CGRectMake(self.bounds.width * 0.1, 0, self.bounds.width * 0.8, self.bounds.height  * 4))
        infoText.adjustsFontSizeToFitWidth = true
        infoText.textAlignment = NSTextAlignment.Left
        infoText.numberOfLines = 12
        infoText.font = UIFont.boldSystemFontOfSize(18)
        infoText.textColor = UIColor.blackColor()
        self.addSubview(infoText)
        
        answerText = UILabel(frame: CGRectMake(self.bounds.width * 0.05, 0, self.bounds.width * 0.9, self.bounds.height))
        answerText.adjustsFontSizeToFitWidth = true
        answerText.textAlignment = NSTextAlignment.Center
        answerText.font = UIFont.boldSystemFontOfSize(24)
        answerText.textColor = UIColor.whiteColor()
        self.addSubview(answerText)
        
        let informationIconSide = self.bounds.height * 0.4
        informationIcon = UILabel(frame: CGRectMake(self.bounds.width - informationIconSide, self.bounds.height - (informationIconSide * 0.75), informationIconSide, informationIconSide))
        informationIcon.text = "ℹ"
        informationIcon.alpha = 0
        informationIcon.font = UIFont.boldSystemFontOfSize(18)
        self.addSubview(informationIcon)
    }
    
    var orgFrame:CGRect!
    var orgInfoFrame:CGRect!
    func tapAnswer(gesture:UITapGestureRecognizer)
    {
        let midscreen = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        if self.center == midscreen
        {
            
            //let heightRatio = imageView.image!.size.height / (self.bounds.height - 3)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.infoText.alpha = 0
                self.frame = self.orgFrame
                self.infoText.frame = self.orgInfoFrame
                self.informationIcon.alpha = 1
                }, completion: { (value: Bool) in
            })
            
        }
        else
        {
            orgFrame = self.frame
            orgInfoFrame = infoText.frame
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = UIScreen.mainScreen().bounds
                self.infoText.alpha = 1
                self.informationIcon.alpha = 0
                self.infoText.center = midscreen
                }, completion: { (value: Bool) in
            })
        }
        
        
    }
    
    
    func setAnswer(question:Question, distance:Int)
    {
        informationIcon.alpha = 0
        print("setQueston called")
        let template = question.answerTemplate.stringByReplacingOccurrencesOfString("$", withString: question.place.name, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let usingKm = NSUserDefaults.standardUserDefaults().boolForKey("useKm")
        let distanceInRightMeasure:String =  usingKm ? "\(distance)" : "\(Int(CGFloat(distance) * 0.621371))"
        let measurement = usingKm ? "km" : "miles"
        answerText.text = distance > 0 ? "\(distanceInRightMeasure) \(measurement) \(template)" : "Correct location of \(question.place.name)"
        

        
        infoText.text = question.place.info
        infoText.alpha = 0
    }
    
    func finishedAnimating()
    {
        self.answerText.textColor = UIColor.blackColor()
        self.informationIcon.alpha = 1
    }
}
