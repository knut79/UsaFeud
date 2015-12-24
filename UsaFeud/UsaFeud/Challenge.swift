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


