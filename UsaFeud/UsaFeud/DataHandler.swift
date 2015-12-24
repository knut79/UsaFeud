//
//  PopulateData.swift
//  TimeIt
//
//  Created by knut on 18/07/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class DataHandler
{
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    //var placeItems:[Place]!
    var questionItems:[Question]!
    var todaysYear:Double!
    init()
    {
        loadGameData()
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year, fromDate: date)
        todaysYear = Double(components.year)
        
        questionItems = []
    }
    
    func readTxtFile(name:String, tags:String = "")
    {
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "txt"){
            do{
            let data = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)

                let myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                var lines:[CGPoint] = []
                var questions:[Question] = []
                for textline in myStrings
                {
                    
                    
                    let elements = textline.componentsSeparatedByString(";")

                        let type = elements[0]
                        if type == "eof"
                        {
                            break
                        }
                        else if type == "qst" // additional question
                        {
                            let questionElements = elements[1].componentsSeparatedByString("#")
                            let uniqueId = questionElements[0]
                            if uniqueId == ""
                            {
                                fatalError("No unique id for question")
                            }
                            //_?
                            let hmmm1 = questionElements[1]
                            if hmmm1 != ""
                            {
                                print("hmmm1 = \(hmmm1)")
                            }
                            let level = questionElements[2]
                            let intStringLevel = level.substringFromIndex(level.startIndex.advancedBy(level.characters.count - 1))
                            let image = questionElements[3]
                            
                            //tag hack
                            var tagsForNonDefaultQuestion = tags
                            if image != ""
                            {
                                tagsForNonDefaultQuestion = "\(tagsForNonDefaultQuestion)#flag"
                            }
                            
                            let englishText = questionElements[4]
                            
                            //print("tags for default question: \(tagsForNonDefaultQuestion)")
                            let question = Question.createInManagedObjectContext(self.managedObjectContext,uniqueId:uniqueId, text: englishText, level:Int(intStringLevel)!, image:image,answerTemplate: "from $",tags: tagsForNonDefaultQuestion)
                            questions.append(question)
                            
                        }
                        else if type == "inf"
                        {
                            let typeAndQuestonOverrideElements = elements[1].componentsSeparatedByString("#")
                            let type = typeAndQuestonOverrideElements[0]
                            let overrideQuestionTemplateText:String? = typeAndQuestonOverrideElements.count > 1 ? typeAndQuestonOverrideElements[1] : nil
                            let name = elements[2]
                            //_?
                            /*
                            let hmmm2 = elements[3]
                            if hmmm2 != ""
                            {
                                print("hmmm2 = \(hmmm2)")
                            }
                            */
                            
                            var intStringLevel = "0"
                            var info = ""
                            var hint1 = ""
                            var hint2 = ""
                            var excludePlaces = ""
                            var includePlaces = ""
                            var addDefaultQuestion = false
                            var tagsForDefaultQuestion = tags
                            if elements[4] != "notUsed"
                            {
                                addDefaultQuestion = true
                                let level = elements[4]
                                intStringLevel = level.substringFromIndex(level.startIndex.advancedBy(level.characters.count - 1))//String(level.characters.last)
                                let infoElements = elements[5].componentsSeparatedByString("#")
                                info = infoElements[0]
                                
                                let hintElements = elements[6].componentsSeparatedByString("#")
                                
                                hint1 = hintElements[0]
                                hint2 = hintElements[1]
                                
                                if elements.count > 7
                                {
                                    excludePlaces = elements[7]
                                    if elements.count > 8
                                    {
                                        includePlaces = elements[8]
                                    }
                                }
                                if elements.count > 9
                                {
                                    tagsForDefaultQuestion = "\(tagsForDefaultQuestion)\(elements[9] as String)"
                                }
                            }
                            
                            let typeInt = Int16(typeStringToEnum(type).rawValue)
                            
                            let place = Place.createInManagedObjectContext(self.managedObjectContext, name: name, refId:"", type:typeInt,info:info, hint1:hint1, hint2:hint2,includePlaces:includePlaces, excludePlaces:excludePlaces)
                            
                            if addDefaultQuestion
                            {
                                addDefaultQuestionForPlace(place,level: Int(intStringLevel)!, overrideQuestionText: overrideQuestionTemplateText,tags: tagsForDefaultQuestion)
                            }
                            
                            
                            if lines.count == 1
                            {
                                let linePoint = LinePoint.createInManagedObjectContext(self.managedObjectContext, point: lines[0],sort:0 )
                                place.addLinePoint(linePoint)
                            }
                            else
                            {
                                for var i = 0 ; i < lines.count; i++
                                {
                                    let linePoint = LinePoint.createInManagedObjectContext(self.managedObjectContext, point: lines[i],sort:i)
                                    place.addLinePoint(linePoint)
                                }
                            }
                            
                            for item in questions
                            {
                                place.addQuestion(item)
                            }
                            //save()
                            
                            questions = []
                            lines = []
                        }
                        else
                        {
                            let x = CGFloat((elements[0] as NSString).floatValue)
                            let y = CGFloat((elements[1] as NSString).floatValue)
                            lines.append(CGPointMake( x,  y ))
                            
                        }
                    
                    //print(textline)
                }
                save()
            
            }
            catch
            {
                print(error)
            }
        }
    }

    
    func typeStringToEnum(typeString:String) -> PlaceType
    {
        if typeString == "City"
        {
            return PlaceType.City
        }
        else if typeString == "Mountain"
        {
            return PlaceType.Mountain
        }
        else if typeString == "UnDefPlace"
        {
            return PlaceType.UnDefPlace
        }
        else if typeString == "State"
        {
            return PlaceType.State
        }
        else if typeString == "County"
        {
            return PlaceType.County
        }
        else if typeString == "Lake"
        {
            return PlaceType.Lake
        }
        else if typeString == "UnDefWaterRegion"
        {
            return PlaceType.UnDefWaterRegion
        }
        else if typeString == "Island"
        {
            return PlaceType.Island
        }
        else if typeString == "Peninsula"
        {
            return PlaceType.Peninsula
        }
        else if typeString == "UnDefRegion"
        {
            return PlaceType.UnDefRegion
        }
        else
        {
            fatalError("Could not find type \(typeString)")
        }
    }

    
    func addDefaultQuestionForPlace(place:Place, level:Int, overrideQuestionText:String?, tags:String)
    {
        var questionText = "Where is \(place.name) located"
        var answerText = "from $"

        let placeType = PlaceType(rawValue: Int(place.type))
        switch(placeType!)
        {
            case .City :
                questionText = "Where is the city \(place.name) located"
            break
            case .Mountain:
                questionText = "Where is the mountain \(place.name) located"
            break
            case .State:
                questionText = "Where is the country \(place.name) located"
                answerText = "from $ border"
            break
            case .County:
                questionText = "Where is the county \(place.name) located"
                answerText = "from $ county border"
            break
            case .Lake:
                questionText = "Where is \(place.name) located"
                answerText = "from $s waterfront"
            break
            default:
                questionText = "Where is \(place.name) located"
                answerText = "from $"
            break

        }
        
        if let qtext = overrideQuestionText
        {
            questionText = "\(qtext) \(place.name)"
        }
        //print("tags for default question: \(tags)")
        let question = Question.createInManagedObjectContext(self.managedObjectContext,uniqueId: place.name, text: questionText, level:level, image:"", answerTemplate:answerText,tags: tags)
        place.addQuestion(question)
    }
    
    
    func populateData(completePopulating: (() -> (Void))?)
    {
        
        readTxtFile("statesAfrica",tags: "#africa")
        readTxtFile("statesAsia",tags: "#asia")
        readTxtFile("statesEastAsia",tags: "#asia")
        readTxtFile("statesEurope",tags: "#europe")
        readTxtFile("statesSouthAmerica",tags: "#southamerica#america")
        readTxtFile("statesNorthAmerica",tags: "#northamerica#america")
        readTxtFile("statesOceania",tags: "#oceania")
        
        readTxtFile("lakes",tags: "#water")
        readTxtFile("waterRegions",tags: "#water")
        
        readTxtFile("capitalsAfrica",tags: "#capital#africa#city")
        readTxtFile("capitalsAsia",tags: "#capital#asia#city")
        readTxtFile("capitalsMiddleEast",tags: "#capital#asia#city")
        readTxtFile("capitalsEurope",tags: "#capital#europe#city")
        readTxtFile("capitalsSouthAmerica",tags: "#capital#america#city")
        
        readTxtFile("places")
        readTxtFile("islands",tags: "#island")
        readTxtFile("cities",tags: "#city")


        //savePeriodesFromCollection(dataToPopulate)
        print("populated new data")
        save()
        dataPopulatedValue = 1
        saveGameData()
        completePopulating?()
    }
    
    func shuffleQuestions()
    {
        questionItems = shuffle(questionItems)
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let ecount = list.count
        for i in 0..<(ecount - 1) {
            let j = Int(arc4random_uniform(UInt32(ecount - i))) + i
            if j != i {
                swap(&list[i], &list[j])
            }
        }
        return list
    }


    func save() {

        do{
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    func orderOnUsed()
    {
        questionItems = questionItems.sort { $0.used < $1.used }
    }
    
    func getXNumberOfQuestionIds(numQuestions:Int) -> [String]
    {
        var questionIds:[String] = []
        for var i = 0 ; i < numQuestions ; i++
        {
            questionIds.append(questionItems[i].uniqueId)
            //questionItems[i].
        }
        return questionIds
    }
    
    func fetchData(tags:[String] = [],fromLevel:Int = 1,toLevel:Int = 1) {
        
        // Create a new fetch request using the LogItem entity
        // eqvivalent to select * from Relation
        let fetchEvents = NSFetchRequest(entityName: "Question")
        
        //let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        

        
        var predicateTags:String = ""
        if tags.count > 0
        {
            for item in tags
            {
                if item != ""
                {
                    predicateTags = "\(predicateTags)|\(item)"
                }
            }
            predicateTags.removeAtIndex(predicateTags.startIndex)
        }
        /*
        let predicate = NSPredicate(format: "periods.@count > 0 AND level >= \(fromLevel) AND level <= \(toLevel) AND tags  MATCHES '.*(\(predicateTags)).*'")//
        fetchEvents.predicate = predicate
        */
        let predicate = NSPredicate(format: "level >= \(fromLevel) AND level <= \(toLevel) AND tags  MATCHES '.*(\(predicateTags)).*'")//
        fetchEvents.predicate = predicate
        
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchEvents)) as? [Question] {
            questionItems = fetchResults
        }
        
    }
    
    func fetchPlace(idRef:String) -> Place?
    {
        let fetchEvents = NSFetchRequest(entityName: "Place")
        
        let predicate = NSPredicate(format: "refId = '\(idRef)'")
        fetchEvents.predicate = predicate

        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchEvents)) as? [Place] {
            return fetchResults.first
        }
        else
        {
            return nil
        }
    }
    
    
    func fetchQuestion(idRef:String) -> Question?
    {
        let fetchEvents = NSFetchRequest(entityName: "Question")
        
        let predicate = NSPredicate(format: "uniqueId = '\(idRef)'")
        fetchEvents.predicate = predicate
        
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchEvents)) as? [Question] {
            return fetchResults.first
        }
        else
        {
            return nil
        }
    }
    
    func fetchPlaces(idRefs:String) -> [Place]?
    {
        if idRefs != ""
        {
            let fetchEvents = NSFetchRequest(entityName: "Place")
            
            let idRefsRightFormat = idRefs.stringByReplacingOccurrencesOfString("#", withString: "|", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            //let predicate = NSPredicate(format: "refId MATCHES '.*(\(idRefsRightFormat)).*'")
            let predicate = NSPredicate(format: "refId MATCHES '(\(idRefsRightFormat))'")
            fetchEvents.predicate = predicate
            
            if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchEvents)) as? [Place] {

                return fetchResults
            }
        }
        return nil
    }
    
    func fetchAllCountries() -> [Place]?
    {

            //PlaceType.State.rawValue

        let fetchEvents = NSFetchRequest(entityName: "Place")

        
        //let predicate = NSPredicate(format: "refId MATCHES '.*(\(idRefsRightFormat)).*'")
        let predicate = NSPredicate(format: "type == (\(PlaceType.State.rawValue))")
        fetchEvents.predicate = predicate
        
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchEvents)) as? [Place] {
            
            return fetchResults
        }
        else
        {
            return nil
        }
    }
    
    func addRecordToGameResults(value:String)
    {
        //self.gameResultsValue.insertObject(value, atIndex: 0)
        self.gameResultsValues.append(value)
    }
    
    let DataPopulatedKey = "DataPopulated"
    let OkScoreKey = "OkScore"
    let GoodScoreKey = "GoodScore"
    let LoveScoreKey = "LoveScore"
    let TagsKey = "Tags"
    let LevelKey = "Level"
    let EventsUpdateKey = "EventsUpdate"
    let GameResultsKey = "GameResults"
    let AdFreeKey = "AdFree"
    let HintsKey = "Hints"
    let TimeBonusKey = "TimeBonus"
    let UseKmKey = "UseKm"
    let DeviceTokenKey = "DeviceToken"
    
    
    var dataPopulatedValue:AnyObject = 0
    var okScoreValue:AnyObject = 0
    var goodScoreValue:AnyObject = 0
    var loveScoreValue:AnyObject = 0
    var tagsValue:AnyObject = 0
    var levelValue:AnyObject = 0
    var eventsUpdateValue:AnyObject = 0
    var adFreeValue:AnyObject = 0
    var hintsValue:AnyObject = 0
    var timeBounusValue:AnyObject = 0
    var useKmValue:AnyObject = 1
    var deviceTokenValue:AnyObject = 0
    var gameResultsValues:[AnyObject] = []

    func loadGameData() {
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = (documentsDirectory as NSString).stringByAppendingPathComponent("GameData.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                do {
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                } catch _ {
                }
                print("copy")
            } else {
                print("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            print("GameData.plist already exits at path. \(path)")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        let myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            dataPopulatedValue = dict.objectForKey(DataPopulatedKey)!
            okScoreValue = dict.objectForKey(OkScoreKey)!
            goodScoreValue = dict.objectForKey(GoodScoreKey)!
            loveScoreValue = dict.objectForKey(LoveScoreKey)!
            tagsValue = dict.objectForKey(TagsKey)!
            levelValue = dict.objectForKey(LevelKey)!
            eventsUpdateValue = dict.objectForKey(EventsUpdateKey)!
            adFreeValue = dict.objectForKey(AdFreeKey)!
            NSUserDefaults.standardUserDefaults().setBool(adFreeValue as! NSNumber == 1 ? true : false, forKey: "adFree")
            useKmValue = dict.objectForKey(UseKmKey)!
            NSUserDefaults.standardUserDefaults().setBool(adFreeValue as! NSNumber == 1 ? true : false, forKey: "useKm")
            hintsValue = dict.objectForKey(HintsKey)!
            NSUserDefaults.standardUserDefaults().setInteger(Int(hintsValue as! NSNumber), forKey: "hintsLeftOnAccount")
            timeBounusValue = dict.objectForKey(TimeBonusKey)!
            NSUserDefaults.standardUserDefaults().setInteger(Int(timeBounusValue as! NSNumber), forKey: "timeBonus")
            deviceTokenValue = dict.objectForKey(DeviceTokenKey)!
            NSUserDefaults.standardUserDefaults().setValue(deviceTokenValue as! String, forKey: "deviceToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            gameResultsValues = dict.objectForKey(GameResultsKey)! as! [AnyObject]
        } else {
            print("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
    }
    
    func saveGameData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(dataPopulatedValue, forKey: DataPopulatedKey)
        dict.setObject(okScoreValue, forKey: OkScoreKey)
        dict.setObject(goodScoreValue, forKey: GoodScoreKey)
        dict.setObject(loveScoreValue, forKey: LoveScoreKey)
        dict.setObject(tagsValue, forKey: TagsKey)
        dict.setObject(levelValue, forKey: LevelKey)
        dict.setObject(eventsUpdateValue, forKey: EventsUpdateKey)
        dict.setObject(adFreeValue, forKey: AdFreeKey)
        dict.setObject(useKmValue, forKey: UseKmKey)
        dict.setObject(hintsValue, forKey: HintsKey)
        dict.setObject(timeBounusValue, forKey: TimeBonusKey)
        dict.setObject(deviceTokenValue, forKey: DeviceTokenKey)
        dict.setObject(gameResultsValues, forKey: GameResultsKey)
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
       // let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Saved GameData.plist file is --> \(resultDictionary?.description)")
    }
    
    func getMaxTimeLimit(year: Double) -> Double
    {
        return year > todaysYear ? todaysYear : year
    }
}


