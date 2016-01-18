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
 
    /*
    
    var sortedPointsExpandedObsoete:[CGPoint]
        {
        get{
            
            let expandFactor = GlobalConstants.placeWindowExpandFactor
            let sortedArray = sortedPoints
            var nonPositionedExpandedPointsArray:[CGPoint] = []
            var minOrgX:CGFloat = GlobalConstants.constMapWidth
            var maxOrgX:CGFloat = 0
            var minOrgY:CGFloat = GlobalConstants.constMapHeight
            var maxOrgY:CGFloat = 0
            
            //can expand out of map bounds
            var minExpandedX:CGFloat = GlobalConstants.constMapWidth * 2
            var maxExpandedX:CGFloat = 0
            var minExpandedY:CGFloat = GlobalConstants.constMapHeight * 2
            var maxExpandedY:CGFloat = 0
            
            for item in sortedArray
            {
                minOrgX = CGFloat(item.x) < minOrgX ? CGFloat(item.x) : minOrgX
                maxOrgX = CGFloat(item.x) > maxOrgX ? CGFloat(item.x) : maxOrgX
                minOrgY = CGFloat(item.y) < minOrgY ? CGFloat(item.y) : minOrgY
                maxOrgY = CGFloat(item.y) > maxOrgY ? CGFloat(item.y) : maxOrgY
                let expandedPoint = CGPointMake(CGFloat(item.x) * expandFactor, CGFloat(item.y) * expandFactor)
                minExpandedX = expandedPoint.x < minExpandedX ? expandedPoint.x : minExpandedX
                maxExpandedX = expandedPoint.x > maxExpandedX ? expandedPoint.x : maxExpandedX
                minExpandedY = expandedPoint.y < minExpandedY ? expandedPoint.y : minExpandedY
                maxExpandedY = expandedPoint.y > maxExpandedY ? expandedPoint.y : maxExpandedY
                nonPositionedExpandedPointsArray.append(expandedPoint)
            }
            
            let centerPointOriginal = CGPointMake((minOrgX + maxOrgX) / 2, (minOrgY + maxOrgY) / 2)
            let centerPointExpanded = CGPointMake((minExpandedX + maxExpandedX) / 2, (minExpandedY + maxExpandedY) / 2)
            
            let clicksToMoveXCoordinate = centerPointExpanded.x - centerPointOriginal.x
            let clicksToMoveYCoordinate = centerPointExpanded.y - centerPointOriginal.y
            
            var positionedExpandedPointsArray:[CGPoint] = []
            for item in nonPositionedExpandedPointsArray
            {
                let positionedPoint = CGPointMake(item.x - clicksToMoveXCoordinate, item.y - clicksToMoveYCoordinate)
                positionedExpandedPointsArray.append(positionedPoint)
            }
            

            return positionedExpandedPointsArray
            
        }
    
    }*/
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