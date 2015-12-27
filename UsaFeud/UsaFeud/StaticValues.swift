//
//  StaticValues.swift
//  TimeIt
//
//  Created by knut on 18/07/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit


//City
//Where is the city %@ located
//, Mountain,
//Where is the mountain %@ located
//UnDefPlace
//else
//Where is %@ located"
//from %

//State
//Where is the state %@ located
//from %@ state border
//County
//Where is the county %@ located
//from %@ county border
//Lake
//from %@s waterfront
//
//UnDefWaterRegion
//Island
//Peninsula
//UnDefRegion
//Where is %@ located
//from %@





struct GlobalConstants {
    static let constMapHeight:CGFloat = 3980
    static let constMapWidth:CGFloat = 5000
    
    static let minLevel:Int = 1
    static let maxLevel:Int = 5
    
    static let smallButtonSide:CGFloat = 40
    static let timeBonusMultiplier:Double = 1.2
    static let hintCostForTimeBonus:Int = 5
    static let timeStart:Double = 14
    static let numberOfQuestionsForChallenge:Int = 7
    static let numberOfHintsPrBuy:Int = 12
    
    static let bailedValue = 9999999
    
    static let indexOfOpponentNameInGamerecordRow = 1
    static let indexOfOpponentIdInGamerecordRow = 5
    
    static let playerSymbolName = "crosshair4.png"
    static let playerSymbolNameInMagnify = "crosshair.png"
}


enum GameType: Int
{
    case training = 0, makingChallenge = 1, takingChallenge = 2
}

enum PlaceType: Int
{
    case City = 0,
    Mountain = 1,
    UnDefPlace = 2,
    State = 3,
    County = 4,
    Lake = 5,
    UnDefWaterRegion = 6,
    Island = 7,
    Peninsula = 8,
    UnDefRegion = 9
}


