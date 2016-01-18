//
//  File.swift
//  PlaceInTime
//
//  Created by knut on 14/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class Challenge {
    
    var questionIds:[String] = []
    var challengeIds:String!
    var title:String!

    
    init()
    {
        questionIds = []
    }
}

class BadgeChallenge: Challenge {

    var image:UIImage!
    var usingBorders:Int!
    var distancePixelsWindow:CGFloat!
    var won:Bool!
    
    init(title:String,image:String,questionIds:[String], border:Int = 0, distancePixelsWindow:CGFloat? = nil)
    {
        super.init()
        
        self.title = title
        self.questionIds = questionIds
        self.image = UIImage(named: image)
        self.usingBorders = border
        if distancePixelsWindow == nil
        {
            let defaultDistancePixelsWindow = GlobalConstants.pointOkWindowOutlineRadius
            self.distancePixelsWindow = defaultDistancePixelsWindow
        }
        else
        {
            self.distancePixelsWindow = distancePixelsWindow
        }
        won = true
    }
    
    func setComplete()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: title)
    }
}

class TakingChallenge: Challenge {

    var id:String!
    var fbIdToBeat:String!
    var distanceToBeat:Int!
    var usingBorders:Int!

    
    let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
    
    init(values:NSDictionary)
    {
        super.init()
        
        title = values["title"] as! String
        id = values["challengeId"] as! String
        fbIdToBeat = values["fbIdToBeat"] as! String
        distanceToBeat = values["distanceToBeat"] as! Int
        usingBorders = values["borders"] as! Int
        let questionsStringFormat = values["questionsStringFormat"] as! String
        
        let questionIdsStringFormat = questionsStringFormat.componentsSeparatedByString(",")
        for item in questionIdsStringFormat
        {
            questionIds.append(item as String)
        }
    }
    
    func getNextQuestionId() -> String?
    {
        return questionIds.count == 0 ? nil : questionIds.removeLast() as String?
    }
}

class MakingChallenge: Challenge {
    
    var usersToChallenge:[String] = []
    init(challengesName:String,users:[String], questionIds:[String], challengeIds:String)
    {
        super.init()
        self.title = challengesName
        self.questionIds = questionIds
        self.challengeIds = challengeIds
        self.usersToChallenge = users
    }
}


