//
//  BadgeView.swift
//  UsaFeud
//
//  Created by knut on 11/01/16.
//  Copyright © 2016 knut. All rights reserved.
//
import Foundation
import UIKit

protocol BadgeChallengeProtocol
{
    func setBadgeChallenge(badgeChallenge:BadgeChallenge)
}

class BadgeView: UIView, UIAlertViewDelegate {
    
    
    //var hintsLeftText:UILabel!
    
    var imageView:UIImageView!
    var complete:Bool = false
    var badgeChallenge:BadgeChallenge!
    var delegate:BadgeChallengeProtocol?
    var title:String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect,title:String, image:String, questions:[String]) {
        super.init(frame: frame)
        
        self.title = title
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BadgeView.tapBadge(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        imageView = UIImageView(frame: self.bounds)
        imageView.image = UIImage(named: image)
        complete = NSUserDefaults.standardUserDefaults().boolForKey(title)
        
        
        imageView.alpha = complete ? 1 : 0.5
        self.addSubview(imageView)
        
        let firsttry = NSUserDefaults.standardUserDefaults().boolForKey("\(title)firsttry")
        if !firsttry
        {
            let newLabel = UILabel(frame: CGRectMake(0,self.bounds.height * 0.66, self.bounds.width,self.bounds.height * 0.33))
            newLabel.text = "🆕"
            newLabel.textAlignment = NSTextAlignment.Right
            self.addSubview(newLabel)
        }
        
        badgeChallenge = BadgeChallenge(title: title, image: image, questionIds: shuffle(questions))
        
        self.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func tapBadge(gesture:UITapGestureRecognizer)
    {
        if !complete
        {
            let alert = UIAlertView(title: badgeChallenge.title, message: "Take this challenge to earn a new badge", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(title)firsttry")
            delegate?.setBadgeChallenge(badgeChallenge)
        }
    }
    
    
    func shuffle<C: MutableCollectionType where C.Index == Int>( list: C) -> C
    {
        var listMutable = list
        let ecount = list.count
        for i in 0..<(ecount - 1) {
            let j = Int(arc4random_uniform(UInt32(ecount - i))) + i
            if j != i {
                swap(&listMutable[i], &listMutable[j])
            }
        }
        return listMutable
    }
    
}