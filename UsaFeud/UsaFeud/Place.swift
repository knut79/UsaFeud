import Foundation
import CoreData
import UIKit


class Place: NSManagedObject {
    
    @NSManaged var refId: String
    @NSManaged var name: String
    @NSManaged var type:Int16
    @NSManaged var hint1: String
    @NSManaged var hint2: String
    @NSManaged var points: NSSet
    @NSManaged var questions: NSSet
    @NSManaged var info:String
    @NSManaged var includePlaces:String
    @NSManaged var excludePlaces:String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, refId:String, type:Int16, info:String, hint1:String, hint2:String, includePlaces:String, excludePlaces:String) -> Place{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: moc) as! Place
        
        newitem.refId = refId == "" ? name : refId
        newitem.name = name
        
        newitem.type = type
        newitem.info = info
        newitem.hint1 = hint1
        newitem.hint2 = hint2
        newitem.points = NSMutableSet()
        newitem.questions = NSMutableSet()
        
        newitem.includePlaces = includePlaces
        newitem.excludePlaces = excludePlaces
        return newitem
    }
    

    
    var sortedPoints:[LinePoint]
        {
        get{
            var sortedArray:[LinePoint] = []
            let sortDescriptor = NSSortDescriptor(key: "sort", ascending: true)
            sortedArray = self.points.sortedArrayUsingDescriptors([sortDescriptor]) as! [LinePoint]
            
            return sortedArray
        }
    }
}

extension Place {
    
    func addLinePoint(point:LinePoint) {
        
        var points: NSMutableSet
        points = self.mutableSetValueForKey("points")
        points.addObject(point)
    }
    
    func addQuestion(question:Question) {
        
        var questions: NSMutableSet
        questions = self.mutableSetValueForKey("questions")
        questions.addObject(question)
    }
    

}