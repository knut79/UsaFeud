//
//  ResultItemView.swift
//  PlaceInTime
//
//  Created by knut on 17/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class ResultItemView: UIView,UIGestureRecognizerDelegate
{
    var title:String!
    var stateWin:Int = 0
    var stateLoss:Int = 0
    var orgFrame:CGRect!
    
    let borderBackgroudView = UIView(frame: CGRectZero)
    let myStateLabel = UILabel(frame: CGRectZero)
    let myDistancePointsLabel = UILabel(frame: CGRectZero)
    let opponentNameLabel = UILabel(frame: CGRectZero)
    let opponentDistanceLabel = UILabel(frame: CGRectZero)
    var opponentFullName:String!
    var opponentFirstName:String!
    var opponentId:String!
    var dateString:String!
    var titleString:String!
    var opponentDistanceInt:Int!
    var myDistanceInt:Int!
    var newRecord:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect,myDistance:Int,opponentName:String,opponentId:String,opponentDistance:Int, title:String, date:String, newRecord:Bool = false) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()

        self.newRecord = newRecord
        dateString = date
        titleString = title.componentsSeparatedByString("from")[0]
        
        borderBackgroudView.layer.borderWidth = 2
        borderBackgroudView.alpha = 1
        
        borderBackgroudView.layer.cornerRadius = 5
        borderBackgroudView.layer.masksToBounds = true
        borderBackgroudView.layer.borderColor = UIColor.blueColor().CGColor
        borderBackgroudView.backgroundColor = UIColor.whiteColor()
        borderBackgroudView.layer.borderWidth = 2
        self.addSubview(borderBackgroudView)
        
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapForDetails:")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.delegate = self
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(singleTapGestureRecognizer)

        opponentFullName = opponentName
        opponentFirstName = opponentName
        if opponentFullName.componentsSeparatedByString(" ").count > 1
        {
            opponentFirstName = opponentFullName.componentsSeparatedByString(" ").first!
        }

        stateWin = 1
        if opponentDistance < myDistance
        {
            stateWin = 0
            stateLoss = 1
        }
        else if myDistance == opponentDistance
        {
            stateWin = 0
        }
        

        myStateLabel.textAlignment = NSTextAlignment.Center
        myStateLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(myStateLabel)
        
        myDistanceInt = myDistance
        myDistancePointsLabel.textAlignment = NSTextAlignment.Center
        myDistancePointsLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(myDistancePointsLabel)
        

        self.opponentId = opponentId
        
        opponentNameLabel.textAlignment = NSTextAlignment.Center
        opponentNameLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(opponentNameLabel)
        
        opponentDistanceInt = opponentDistance
        opponentDistanceLabel.textAlignment = NSTextAlignment.Center
        opponentDistanceLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(opponentDistanceLabel)
        
        orgLayout()
    }
    
    func orgLayout()
    {
        
        borderBackgroudView.alpha = 0
        borderBackgroudView.transform = CGAffineTransformScale(borderBackgroudView.transform, 0.1, 0.1)
        
        let margin:CGFloat = 0
        let secondLevelTitleWidth:CGFloat = (self.bounds.width - ( margin * 2)) / 4
        let titleElementHeight:CGFloat = 40
        
        var state = "✅"
        if stateWin == 0 && stateLoss == 1
        {
            state = "❌"
        }
        else if stateWin == 0
        {
            state = "➖"
        }
        if newRecord
        {
            state = "\(state)🆕"
        }
        myStateLabel.frame = CGRectMake(margin , 0, secondLevelTitleWidth, titleElementHeight)
        myStateLabel.text = "\(state)"

        borderBackgroudView.center = myStateLabel.center
        myDistancePointsLabel.font = opponentDistanceLabel.font
        myDistancePointsLabel.frame = CGRectMake(myStateLabel.frame.maxX , 0, secondLevelTitleWidth, titleElementHeight)
        myDistancePointsLabel.text = myDistanceInt ==  GlobalConstants.bailedValue ? "Bailed❗" : "\(myDistanceInt)"
        opponentNameLabel.frame = CGRectMake(myDistancePointsLabel.frame.maxX , 0, secondLevelTitleWidth, titleElementHeight)
        opponentNameLabel.text = "\(opponentFirstName)"
        opponentDistanceLabel.frame = CGRectMake(opponentNameLabel.frame.maxX , 0, secondLevelTitleWidth, titleElementHeight)
        opponentDistanceLabel.text = opponentDistanceInt ==  GlobalConstants.bailedValue ? "Bailed❗" : "\(opponentDistanceInt)"
    }
    
    func detailLayout()
    {
        let margin = frame.width * 0.2
        borderBackgroudView.transform = CGAffineTransformIdentity
        borderBackgroudView.frame = CGRectMake(margin, margin, self.superview!.bounds.width - (margin * 2), self.superview!.bounds.height - (margin * 2))
        
        borderBackgroudView.alpha = 1
        
        var state = "You won against"
        if stateWin == 0 && stateLoss == 1
        {
            state = "You lost against"
        }
        else if stateWin == 0
        {
            state = "You drew against"
        }
        let titleElementHeight:CGFloat = 40

        let labelMargin = borderBackgroudView.frame.width * 0.1
        let labelWidth = borderBackgroudView.frame.width - (labelMargin * 2)
        myDistancePointsLabel.frame = CGRectMake(borderBackgroudView.frame.minX + labelMargin, borderBackgroudView.frame.midY - (titleElementHeight * 2), labelWidth, titleElementHeight)
        myDistancePointsLabel.text = "\(titleString)"
        myDistancePointsLabel.font = UIFont.boldSystemFontOfSize(30)
        
        myStateLabel.frame = CGRectMake(myDistancePointsLabel.frame.minX , myDistancePointsLabel.frame.maxY, labelWidth, titleElementHeight)
        myStateLabel.text = "\(state)"
        opponentNameLabel.frame = CGRectMake(myDistancePointsLabel.frame.minX , myStateLabel.frame.maxY, labelWidth, titleElementHeight)
        opponentNameLabel.text = "\(opponentFullName)"
        opponentDistanceLabel.frame = CGRectMake(myDistancePointsLabel.frame.minX , opponentNameLabel.frame.maxY, labelWidth, titleElementHeight)
        opponentDistanceLabel.text = "\(dateString)"

    }
    
    var expandedForDetails = false
    func tapForDetails(gesture:UITapGestureRecognizer)
    {
        self.superview?.bringSubviewToFront(self)
        borderBackgroudView.center = self.center
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if !self.expandedForDetails
            {
                
                self.expandedForDetails = true
                self.orgFrame = self.frame
                let yOffset = (self.superview as! UIScrollView).contentOffset.y
                //let margin = (self.superview?.bounds.width)! * 0.2
                self.frame = CGRectMake(0, 0 + yOffset, self.superview!.bounds.width, self.superview!.bounds.height)
                self.detailLayout()
                
            }
            else
            {
                self.expandedForDetails = false
                self.frame = self.orgFrame
                print("tap \(self.orgFrame.minX) \(self.orgFrame.minY) \(self.orgFrame.width) \(self.orgFrame.height)")
                self.orgLayout()
            }

        })
    }
}