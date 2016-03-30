//
//  CoordinateHelper.swift
//  MapFeud
//
//  Created by knut on 13/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class CoordinateHelper {
    
    var includedRegions:[[LinePoint]] = []
    var excludedRegions:[[LinePoint]] = []
    init()
    {
    }
    
    func convertFromLinePointsToPoints(collection:[[LinePoint]]) -> [[CGPoint]]
    {
        var pointCollections:[[CGPoint]] = []
        for region in collection
        {
            var pointCollection:[CGPoint] = []
            for linePoint in region
            {
                let linePoint = linePoint as LinePoint
                pointCollection.append(CGPointMake(CGFloat(linePoint.x), CGFloat(linePoint.y)))
            }
            pointCollections.append(pointCollection)
        }
        return pointCollections
    }
    
    func getRectOfIncludedAreas() -> CGRect
    {
        var minX:CGFloat = CGFloat.max, minY:CGFloat = CGFloat.max, maxX:CGFloat = 0.0 , maxY:CGFloat = 0.0
        
        let includedPointCollections = convertFromLinePointsToPoints(includedRegions)
        
        if includedPointCollections.count == 1 && includedPointCollections[0].count == 1
        {
            return CGRectMake(includedPointCollections[0][0].x - 5, includedPointCollections[0][0].y - 5, 10, 10)
        }
        else
        {
        
            for j in 0 ..< includedPointCollections.count
            {
                let vertices = includedPointCollections[j]
                for i in 0 ..< vertices.count
                {
                    if vertices[i].x < minX
                    {
                        minX = vertices[i].x
                    }
                    if vertices[i].x > maxX
                    {
                        maxX = vertices[i].x
                    }
                    if vertices[i].y < minY
                    {
                        minY = vertices[i].y
                    }
                    if vertices[i].y > maxY
                    {
                        maxY = vertices[i].y
                    }
                }
            }
            return CGRectMake(minX, minY, maxX - minX, maxY - minY)
        }
        
    }
    
    func isPointInsidePolygon(point:CGPoint,polygon:[LinePoint]) -> Bool
    {
        var wrappingArray:[[LinePoint]] = []
        wrappingArray.append(polygon)
        let includedPointCollections = convertFromLinePointsToPoints(wrappingArray)
        let inside = point.isInsidePolygons(includedPointCollections)
        return inside
    }
    
    //Returns nil if correct answer
    func getNearestPoint(point:CGPoint,includedRegions:[[LinePoint]], excludedRegions:[[LinePoint]]) -> CGPoint?
    {
        self.includedRegions = includedRegions
        self.excludedRegions = excludedRegions
        //check if point is within any of the polygons
        //..... get nearest border point
        //else .. check if point within exluded area
        //......get nearest border point
        
        var nearestPoint:CGPoint?

        let includedPointCollections = convertFromLinePointsToPoints(includedRegions)
        
        //check if inside any of the included regions

        let inside = point.isInsidePolygons(includedPointCollections)

        
        if inside == false
        {
            nearestPoint = point.nearestPointInPolygons(includedPointCollections)
        }
        else
        {
            //check if point inside excluded region
            
            
            let excludedPointCollections = convertFromLinePointsToPoints(excludedRegions)
            let insideExcluded = point.isInsidePolygons(excludedPointCollections)
            if insideExcluded
            {
                nearestPoint = point.nearestPointInPolygons(excludedPointCollections)
            }
        }
        
        //check outside of map on both sides
        if let np = nearestPoint
        {
            let leftNearestPoint = CGPointMake(np.x - GlobalConstants.constMapWidth, np.y)
            let rightNearestPoint = CGPointMake(np.x + GlobalConstants.constMapWidth, np.y)
            let orgDistance = point.distanceFromCGPoints(np)
            let distanceLeftside = point.distanceFromCGPoints(leftNearestPoint)
            let distanceRightside = point.distanceFromCGPoints(rightNearestPoint)
            if orgDistance > distanceLeftside
            {
                let leftPoint = CGPointMake(point.x + GlobalConstants.constMapWidth, point.y)
                nearestPoint = leftPoint.nearestPointInPolygons(includedPointCollections)
                nearestPoint = CGPointMake(nearestPoint!.x - GlobalConstants.constMapWidth, nearestPoint!.y)
                //nearestPoint = leftPoint
            }
            else if orgDistance > distanceRightside // ok
            {
                let rightPoint = CGPointMake(point.x - GlobalConstants.constMapWidth, point.y)
                nearestPoint = rightPoint.nearestPointInPolygons(includedPointCollections)
                nearestPoint = CGPointMake(nearestPoint!.x + GlobalConstants.constMapWidth, nearestPoint!.y)
                //nearestPoint = rightPoint
            }
        }
        return nearestPoint
    }
    
    
    
    func getDistanceInKm(point1:CGPoint, point2:CGPoint?, placeType:PlaceType = PlaceType.County) -> Int
    {
        //float distance = [self GetDistance:point1 andPoint2:point2] ;
        if let toPoint = point2
        {
            let convertedPoint1:CGPoint = self.convertPointToLatLong(point1)
            let convertedPoint2:CGPoint = self.convertPointToLatLong(toPoint)
        
            //haversine
            let distance:CGFloat = self.haversineCalulationDistance(convertedPoint1,pos2: convertedPoint2)
            /*
            test
            CGPoint oslo = CGPointMake(10.75,59.95);
            CGPoint washington = CGPointMake(-77.033333,38.883333);
            float distanceTest = [self HaversineCalulationDistance:washington andPost2:oslo];
            */
            

            if placeType == PlaceType.City || placeType == PlaceType.UnDefPlace || placeType == PlaceType.Mountain
            {
                //this value is just roughly right
                let convertedPointWithRadius:CGPoint = self.convertPointToLatLong(CGPointMake(point1.x + GlobalConstants.pointPerfectWindowOutlineRadius,point1.y + GlobalConstants.pointPerfectWindowOutlineRadius))
                let pointKmRadiusWindow = Int(self.haversineCalulationDistance(convertedPoint1,pos2: convertedPointWithRadius))
                let newDistance = lrintf(Float(distance)) - pointKmRadiusWindow
                return newDistance < 0 ? 0 : newDistance
            }
            else
            {
                return lrintf(Float(distance))
            }

        }
        else
        {
            return 0
        }
    }
    
    func isInsideWindowRadius(playerPoint:CGPoint, mapCordsNearestPoint:CGPoint?, radius:CGFloat) -> Bool
    {
        if let centerPoint = mapCordsNearestPoint
        {
            return isPointInCircle(centerPoint,radius: radius,pointToTest: playerPoint)
        }
        else
        {
            return false
        }
        
    }
    
    //used by isInsideWindowRadius
    func isInRectangle(centerPoint:CGPoint, radius:CGFloat, pointToTest:CGPoint) -> Bool
    {
        return pointToTest.x >= centerPoint.x - radius && pointToTest.x <= centerPoint.x + radius &&
            pointToTest.y >= centerPoint.y - radius && pointToTest.y <= centerPoint.y + radius;
    }

    //used by isInsideWindowRadius
    func isPointInCircle(centerPoint:CGPoint, radius:CGFloat, pointToTest:CGPoint) -> Bool
    {
        if(isInRectangle(centerPoint, radius: radius, pointToTest: pointToTest))
        {
            var dx:CGFloat = centerPoint.x - pointToTest.x;
            var dy:CGFloat = centerPoint.y - pointToTest.y;
            dx *= dx;
            dy *= dy;
            let distanceSquared:CGFloat = dx + dy;
            let radiusSquared:CGFloat = radius * radius;
            return distanceSquared <= radiusSquared;
        }
        return false;
    }
    
    func halfwayPoint(point1: CGPoint, point2:CGPoint) -> CGPoint
    {
        return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2)
    }
    
    
    func haversineCalulationDistance(pos1:CGPoint,pos2:CGPoint) -> CGFloat
    {
        let R:Float = 6371 //km
        //float R = (type == DistanceType.Miles) ? 3960 : 6371;
    
        let temp1:CGFloat = pos2.y - pos1.y
        let dLat:Float = self.toRadian(temp1)
        let temp2:CGFloat = pos2.x - pos1.x
        let dLon:Float = self.toRadian(temp2)
    
        let a:Float = sin(dLat / 2) * sinf(dLat / 2) + cosf(self.toRadian(pos1.y)) * cosf(self.toRadian(pos2.y)) *  sinf(dLon / 2) * sinf(dLon / 2);
        //Math.Min
        let c:Float = 2 * asinf(fminf(1, sqrtf(a)))
        let d:Float = R * c
        return CGFloat(d)
    }
    
    func toRadian(val:CGFloat) -> Float
    {
        return (Float(M_PI) / 180) * Float(val)
    }
    
    
    func convertPointToLatLong(point:CGPoint) -> CGPoint
    {
        var returnPoint = CGPointZero
        returnPoint.x = self.convertToLong(point.x)
        returnPoint.y = self.convertToLat(point.y)
        return returnPoint
    }
    
    func convertToLat(yCoordinate:CGFloat) -> CGFloat
    {
        //
        //float yCoordinateWithOffset = yCoordinate;//119.35;
        //float factor = 2944.0/180.0;
        //float factor = 2944.0/(84.0 + 64.0);
        //
        let mapHeightIfCoversAllDegrees:CGFloat = (GlobalConstants.constMapHeight * 180) / 148
        let factor:CGFloat = mapHeightIfCoversAllDegrees / 180.0
    
        var latValue:CGFloat = yCoordinate / factor
        latValue -= 90.0;
        let latOffset:CGFloat = -22.6
        latValue = latValue + latOffset
        latValue = latValue * -1
    
        return latValue
    }
    
    func convertToLong(xCoordinate:CGFloat) -> CGFloat
    {
    
        let factor:CGFloat = GlobalConstants.constMapWidth / 360.0
        var longValue:CGFloat = xCoordinate / factor
        longValue -= 180.0
        let logitudeOffset:CGFloat = 9
        longValue = longValue + logitudeOffset
    
        return longValue
    }
    
}

extension CGPoint{
    
    func nearestPointInPolygon(vertices:[CGPoint]) -> CGPoint
    {
        var nearestPoint:CGPoint?
        var nearestDistance:CGFloat = CGFloat.max
        for i in 0 ..< vertices.count
        {
            let tempNearestDistance = self.distanceFromCGPoints(vertices[i])
            if tempNearestDistance < nearestDistance
            {
                nearestDistance = tempNearestDistance
                nearestPoint = vertices[i]
            }
        }
        return nearestPoint!
    }
    
    func nearestPointInPolygons(verticesCollection:[[CGPoint]]) -> CGPoint
    {
        var nearestPoint:CGPoint?
        var nearestDistance:CGFloat = CGFloat.max
        for j in 0  ..< verticesCollection.count 
        {
            let vertices = verticesCollection[j]
            for i in 0  ..< vertices.count
            {
                let tempNearestDistance = self.distanceFromCGPoints(vertices[i])
                if tempNearestDistance < nearestDistance
                {
                    nearestDistance = tempNearestDistance
                    nearestPoint = vertices[i]
                }
            }
        }
        return nearestPoint!
    }
    
    func distanceFromCGPoints(p:CGPoint)->CGFloat
    {
        return sqrt(pow(x - p.x,2)+pow(y - p.y,2));
    }
    
    func isInsidePolygon(vertices:[CGPoint]) -> Bool
    {
        var j = vertices.count-1, c = false, vi:CGPoint, vj:CGPoint
        for i in 0  ..< vertices.count 
        {
            j = i
            vi = vertices[i]
            vj = vertices[j]
            let par1 = vi.y > y
            let par2 = vj.y > y
            let par3 = vj.x - vi.x
            let par4 = y - vi.y
            let par5 = vj.y - vi.y
            if ( ((par1) != (par2)) &&
                (x < (par3) * (par4) / (par5) + vi.x) ) {
                    c = !c;
            }
        }
        return c
    }
    
    func isInsidePolygons(verticesCollection:[[CGPoint]]) -> Bool {
        var c = false
        for i in 0  ..< verticesCollection.count
        {
            if self.isInsidePolygon(verticesCollection[i])
            {
                c = true
                break
            }
        }
        
        return c
    }
    /*
    func distanceFromCGPoints(a:CGPoint,b:CGPoint)->CGFloat{
        return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));
    }
    */
    
}
