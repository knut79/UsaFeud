//
//  QuestionView.swift
//  MapFeud
//
//  Created by knut on 12/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class QuestionView: UIView {
    
    
    var questionText:UILabel!
    var imageView:UIImageView!
    
    var orgFrame:CGRect!
    var orgImageFrame:CGRect!
    var orgTextPosition:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        questionText = UILabel(frame: CGRectMake(self.bounds.width * 0.05, 0, self.bounds.width * 0.9, self.bounds.height))
        questionText.adjustsFontSizeToFitWidth = true
        questionText.textAlignment = NSTextAlignment.Center
        questionText.font = UIFont.boldSystemFontOfSize(24)
        questionText.textColor = UIColor.whiteColor()
        questionText.userInteractionEnabled = true
        let singleTapGestureRecognizerText = UITapGestureRecognizer(target: self, action: "tapQuestion:")
        singleTapGestureRecognizerText.numberOfTapsRequired = 1
        singleTapGestureRecognizerText.enabled = true
        singleTapGestureRecognizerText.cancelsTouchesInView = false
        questionText.addGestureRecognizer(singleTapGestureRecognizerText)
        self.addSubview(questionText)
        
        imageView = UIImageView(frame: CGRectZero)
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        imageView.userInteractionEnabled = true
        let singleTapGestureRecognizerImage = UITapGestureRecognizer(target: self, action: "tapFlag:")
        singleTapGestureRecognizerImage.numberOfTapsRequired = 1
        singleTapGestureRecognizerImage.enabled = true
        singleTapGestureRecognizerImage.cancelsTouchesInView = false
        imageView.addGestureRecognizer(singleTapGestureRecognizerImage)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "tapFlag:")
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        swipeUpGestureRecognizer.enabled = true
        swipeUpGestureRecognizer.cancelsTouchesInView = false
        imageView.addGestureRecognizer(swipeUpGestureRecognizer)
        
        self.addSubview(imageView)
        
        self.orgFrame = self.frame

        
    }
    
    func tapQuestion(gesture:UITapGestureRecognizer)
    {
        if questionText.numberOfLines == 1
        {
            questionText.numberOfLines = 2
        }
        else
        {
            questionText.numberOfLines = 1
        }
    }
    

    func tapFlag(gesture:UITapGestureRecognizer)
    {
        let midscreen = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        if self.center == midscreen
        {
           //let heightRatio = imageView.image!.size.height / (self.bounds.height - 3)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = self.orgFrame
                self.imageView.frame = self.orgImageFrame
                self.questionText.center = self.orgTextPosition
                }, completion: { (value: Bool) in
                    self.frame = self.orgFrame
                    self.imageView.frame = self.orgImageFrame
                    self.questionText.center = self.orgTextPosition
                    
            })
            
        }
        else
        {
            //orgFrame = self.frame

            let widthRatio = (UIScreen.mainScreen().bounds.width - 20) / imageView.frame.width
            let imageWidth = UIScreen.mainScreen().bounds.width - 20
            let imageheight = imageView.frame.height * widthRatio
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.frame = UIScreen.mainScreen().bounds
                    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageheight)
                    self.imageView.center = midscreen
                    self.questionText.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, self.questionText.center.y)
                }, completion: { (value: Bool) in
                    self.frame = UIScreen.mainScreen().bounds
                    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageheight)
                    self.imageView.center = midscreen
                    self.questionText.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, self.questionText.center.y)
                    
            })
        }

        
    }
    
    
    func setQuestion(question:Question)
    {
        print("setQueston called")
        questionText.text = "\(question.text)?"
        

        if question.image != ""
        {
            if let image = UIImage(named: question.image)
            {
                imageView.alpha = 1
                imageView.image = image
                let heightRatio = image.size.height / (self.bounds.height - 3)
                imageView.frame = CGRectMake(3, 3, image.size.width / heightRatio, self.bounds.height - 6)
                questionText.frame = CGRectMake(imageView.frame.maxX + 3, 0, self.bounds.width - imageView.frame.width - 9, self.bounds.height)
            }
            else
            {
                print("Warning! Could not find picture file \(question.image)")
                questionText.text = "Where is \(question.place.name)?"
                imageView.alpha = 0
                questionText.frame = CGRectMake(self.bounds.width * 0.05, 0, self.bounds.width * 0.9, self.bounds.height)
            }
        }
        else
        {
            imageView.alpha = 0
            questionText.frame = CGRectMake(self.bounds.width * 0.05, 0, self.bounds.width * 0.9, self.bounds.height)
        }
        orgImageFrame = imageView.frame
        print("img orgframe \(orgImageFrame.origin.x) \(orgImageFrame.origin.y) \(orgImageFrame.width) \(orgImageFrame.height)")
        orgTextPosition = questionText.center
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
                self.center = CGPointMake(self.center.x, self.frame.maxY * -1)
            }
        }
        else
        {
            self.frame = self.orgFrame
        }
        
    }
}
