//
//  BadgeView.swift
//  UsaFeud
//
//  Created by knut on 10/01/16.
//  Copyright © 2016 knut. All rights reserved.
//


import Foundation
import UIKit

protocol BadgeCollectionProtocol
{
    func playBadgeChallengeAction()
    func resultMapAction()
}

class BadgeCollectionView: UIView, BadgeChallengeProtocol {
    
    
    //var hintsLeftText:UILabel!
    var resultMap:UIImageView!
    var badgeStates1:BadgeView!
    var badgeBigCities1:BadgeView!
    var badgeCapitals1:BadgeView!
    var badgeBigCities2:BadgeView!
    var badgeCapitals2:BadgeView!
    var badgeFamousCities:BadgeView!
    var badgeCitiesPerfectLocation1:BadgeView!
    var badgeCitiesPerfectLocation2:BadgeView!
    
    var delegate:BadgeCollectionProtocol?
    
    let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
    
    var currentBadgeChallenge:BadgeChallenge?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        let badgesOnOneRow:CGFloat = 8
        let badgesOnColumn:CGFloat = 2
        let marginBetweenBadges:CGFloat = 3
        let marginTopBottom:CGFloat = 3
        let badgeWidth = (self.bounds.width * 0.2) - (marginBetweenBadges * (badgesOnOneRow - 1)) - (marginTopBottom * 2)
        let badgeHeight = (self.bounds.height * 0.5) - (marginBetweenBadges * (badgesOnColumn - 1)) - (marginTopBottom * 2)
        

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "mapAction:")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        resultMap = UIImageView(frame: CGRectMake(marginTopBottom, marginTopBottom, badgeWidth, badgeHeight))
        resultMap.image = UIImage(named: "testbadge.png")
        resultMap.userInteractionEnabled = true
        //resultMap.setTitle("🌐", forState: UIControlState.Normal)
        self.addSubview(resultMap)
        resultMap.addGestureRecognizer(singleTapGestureRecognizer)

        
        
        badgeStates1 = BadgeView(frame: CGRectMake(resultMap.frame.maxX, marginTopBottom, badgeWidth, badgeHeight), title: "test1", image: "testbadge.png",questions: ["New Mexico","Arizona"])
        badgeStates1.delegate = self
        self.addSubview(badgeStates1)
        
        badgeBigCities1 = BadgeView(frame: CGRectMake(badgeStates1.frame.maxX + marginBetweenBadges, marginTopBottom, badgeWidth, badgeHeight),title: "test2",image: "testbadge.png",questions: ["New Mexico","Arizona"])
        badgeBigCities1.delegate = self
        self.addSubview(badgeBigCities1)

        badgeBigCities2 = BadgeView(frame: CGRectMake(badgeBigCities1.frame.maxX + marginBetweenBadges, marginTopBottom, badgeWidth, badgeHeight),title: "test3",image: "testbadge.png",questions: ["New Mexico","Arizona"])
        badgeBigCities2.delegate = self
        self.addSubview(badgeBigCities2)
        
        let nextRowY = badgeStates1.frame.maxY + marginBetweenBadges
        
        badgeCapitals1 = BadgeView(frame: CGRectMake(marginTopBottom, nextRowY, badgeWidth, badgeHeight),title: "testx", image: "testbadge.png",questions: ["New Mexico","Arizona"])
        badgeCapitals1.delegate = self
        self.addSubview(badgeCapitals1)
        
        if badgeCapitals1.complete
        {
            badgeCapitals2 = BadgeView(frame: CGRectMake(badgeCapitals1.frame.maxX + marginTopBottom, nextRowY, badgeWidth, badgeHeight),title: "testxx", image: "testbadge.png",questions: ["New Mexico","Arizona"])
            badgeCapitals2.delegate = self
            self.addSubview(badgeCapitals2)
        }
    }
    
    func mapAction(gesture:UITapGestureRecognizer)
    {
        delegate?.resultMapAction()
    }
    
    func setBadgeChallenge(badgeChallenge:BadgeChallenge)
    {
        currentBadgeChallenge = badgeChallenge
        delegate?.playBadgeChallengeAction()
        
    }
    
}