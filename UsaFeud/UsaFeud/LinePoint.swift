import Foundation
import CoreData
import UIKit

class LinePoint: NSManagedObject {
    
    @NSManaged var x: Float
    @NSManaged var y: Float
    @NSManaged var sort:Int32
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, point:CGPoint, sort:Int) -> LinePoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("LinePoint", inManagedObjectContext: moc) as! LinePoint
        newitem.x = Float(point.x)
        newitem.y = Float(point.y)
        newitem.sort = Int32(sort)
        return newitem
    }
}