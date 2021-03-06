//
//  TileContainerOverlayView.swift
//  MapFeud
//
//  Created by knut on 08/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class TileContainerOverlayLayer: CALayer {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        playerSymbol = UIImage(named: GlobalConstants.playerSymbolName)
    }
    
    var playerSymbol:UIImage!
    var fromPoint:CGPoint?
    var toPoint:CGPoint?
    var regions:[[LinePoint]] = []
    var exludedRegions:[[LinePoint]] = []
    var resolutionPercentage:CGFloat = 100
    var zoomScale:CGFloat = 1
    
    var placeType:PlaceType?
    

    override func drawInContext(ctx: CGContext)
    {
        //CGContextDrawImage(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage)
        //originalImage.drawInRect(CGRectMake(0, 0, originalImage.size.width, originalImage.size.height))
        CGContextSetLineCap(ctx, CGLineCap.Round)
        CGContextSetLineJoin(ctx, CGLineJoin.Round)
        CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        

        if fromPoint != nil && toPoint != nil
        {
            drawLine(ctx)
            //drawPlayerSymbol(ctx)
            //save before setting mask so we can draw upon mask after drawing places
            drawNearestPointWindowOutline(ctx)
            
            CGContextSaveGState(ctx)
        }
        
        //Set fill color
        if toPoint == nil
        {
            //correct region placement
            CGContextSetFillColorWithColor(ctx, UIColor.greenColor().colorWithAlphaComponent(0.9).CGColor)
            
        }
        else
        {
            CGContextSetFillColorWithColor(ctx, UIColor.redColor().colorWithAlphaComponent(0.9).CGColor)
        }
        
        
        
        if let pt = placeType
        {
            if pt == PlaceType.Lake || pt == PlaceType.UnDefWaterRegion
            {
                CGContextSetFillColorWithColor(ctx, UIColor.blueColor().CGColor)
            }
        }
        
        
        if regions.count == 1 && regions[0].count == 1
        {
            drawPoint(ctx)
        }
        else
        {
            
            drawMask(ctx)
            drawPlace(ctx)
        }
        
        
        if fromPoint != nil && toPoint != nil
        {
            CGContextRestoreGState (ctx)

            drawPlayerSymbol(ctx)
        }

        
        self.shouldRasterize = true
    }
    
    func drawPlayerSymbol(context:CGContext)
    {
        
        
        
        //CGContextDrawImage(context, CGRectMake(fromPoint!.x - (side / 2),fromPoint!.y - (side / 2), side, side), playerSymbol.CGImage)
        
        let side = UIScreen.mainScreen().bounds.width * 0.2
        UIGraphicsPushContext(context)
        //playerSymbol?.drawAtPoint(CGPointMake(fromPoint!.x, fromPoint!.y))
        playerSymbol?.drawInRect(CGRectMake(fromPoint!.x * (resolutionPercentage / 100.0) - (side / 2),fromPoint!.y * (resolutionPercentage / 100.0) - (side / 2), side, side))
        UIGraphicsPopContext()
        
        print("Drawing player symbol \(resolutionPercentage)")
        /*
        var c:CGContextRef = UIGraphicsGetCurrentContext()!
        image?.drawInRect(CGRectMake(fromPoint!.x,fromPoint!.y, side, side))

        var contextImage:CGImageRef = CGBitmapContextCreateImage(c)!
        var resultingImage = UIImage imageWithCGImage:contextImage]
        imgView.image=resultingImage;
        CGImageRelease(contextImage);
*/
            
    }
    
    func clearDrawing()
    {
        self.exludedRegions = []
        self.regions = []
        self.fromPoint = nil
        self.toPoint = nil
        self.setNeedsDisplay()
    }
    
    func drawMask(context:CGContext)
    {
        //let maskImage = UIImage(named: "25MaskWater.png" )
        var useLandMask = true
        if let pt = placeType
        {
            if pt == PlaceType.Lake || pt == PlaceType.UnDefWaterRegion
            {
                useLandMask = false
            }
        }
        let maskImage = UIImage(named: useLandMask ? "25MaskLand.png" : "25MaskWater.png")
        //let maskImageScaled = UIImage(CGImage: maskImage!.CGImage!, scale: zoomScale, orientation: UIImageOrientation.Up)
        let scaleSize = CGSizeMake(maskImage!.size.width * zoomScale, maskImage!.size.height * zoomScale)
        UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0);
        maskImage!.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        let maskRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, self.frame.height)
        let mask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(resizedImage.CGImage), CGImageGetHeight(resizedImage.CGImage), CGImageGetBitsPerComponent(resizedImage.CGImage), CGImageGetBitsPerPixel(resizedImage.CGImage), CGImageGetBytesPerRow(resizedImage.CGImage), CGImageGetDataProvider(resizedImage.CGImage), nil, false)!
        //let mask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(maskImage!.CGImage), CGImageGetHeight(maskImage!.CGImage), CGImageGetBitsPerComponent(maskImage!.CGImage), CGImageGetBitsPerPixel(maskImage!.CGImage), CGImageGetBytesPerRow(maskImage!.CGImage), CGImageGetDataProvider(maskImage!.CGImage), nil, false)!

        CGContextClipToMask(context, maskRect, mask)
    }
    
    func drawPoint(context:CGContext)
    {
        let point = regions[0][0]
        CGContextAddArc(context, CGFloat(point.x) * (resolutionPercentage / 100.0), CGFloat(point.y) * (resolutionPercentage / 100.0), GlobalConstants.pointPerfectWindowOutlineRadius * (resolutionPercentage / 100.0), 0.0, CGFloat(M_PI * 2.0), 1)

        CGContextStrokePath(context)
    }
    
    func drawNearestPointWindowOutline(context:CGContext)
    {
        if let point = toPoint
        {
            //if inside window -- green
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
            CGContextSetFillColorWithColor(context, UIColor.greenColor().colorWithAlphaComponent(0.1).CGColor)
            //if outside window -- red
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
            CGContextSetFillColorWithColor(context, UIColor.redColor().colorWithAlphaComponent(0.1).CGColor)
            
            
            CGContextAddArc(context, CGFloat(point.x) * (resolutionPercentage / 100.0), CGFloat(point.y) * (resolutionPercentage / 100.0), GlobalConstants.pointOkWindowOutlineRadius * (resolutionPercentage / 100.0), 0.0, CGFloat(M_PI * 2.0), 1)
        
            //CGContextStrokePath(context)
            CGContextDrawPath(context, CGPathDrawingMode.EOFillStroke)
            
            
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        }
        
        
    }
    
    
    func drawLine(context:CGContext)
    {
        print("Drawing line \(fromPoint!.x),\(fromPoint!.y) -> \(toPoint!.x),\(toPoint!.y)")
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGFloat(fromPoint!.x) * (resolutionPercentage / 100.0), CGFloat(fromPoint!.y) * (resolutionPercentage / 100.0))
        CGContextAddLineToPoint(context, CGFloat(toPoint!.x) * (resolutionPercentage / 100.0) , CGFloat(toPoint!.y) * (resolutionPercentage / 100.0))
        CGContextStrokePath(context)
        //CGContextClosePath(context)
 
        if toPoint!.x > GlobalConstants.constMapWidth
        {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGFloat(fromPoint!.x - GlobalConstants.constMapWidth) * (resolutionPercentage / 100.0), CGFloat(fromPoint!.y) * (resolutionPercentage / 100.0))
            CGContextAddLineToPoint(context, CGFloat(toPoint!.x - GlobalConstants.constMapWidth) * (resolutionPercentage / 100.0) , CGFloat(toPoint!.y) * (resolutionPercentage / 100.0))
            CGContextStrokePath(context)
            //CGContextClosePath(context)
        }
        if toPoint!.x < 0
        {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, CGFloat(fromPoint!.x + GlobalConstants.constMapWidth) * (resolutionPercentage / 100.0), CGFloat(fromPoint!.y) * (resolutionPercentage / 100.0))
            CGContextAddLineToPoint(context, CGFloat(toPoint!.x + GlobalConstants.constMapWidth) * (resolutionPercentage / 100.0) , CGFloat(toPoint!.y) * (resolutionPercentage / 100.0))
            CGContextStrokePath(context)
            //CGContextClosePath(context)
        }
        

    }
    
    func drawPlace(context:CGContext)
    {
        
        for lines in regions
        {
            //CGContextBeginPath(context)
            
            let pathRef:CGMutablePathRef = CGPathCreateMutable()
            
            
            
            let firstPoint = lines[0]
            CGPathMoveToPoint(pathRef,nil, CGFloat(firstPoint.x) * (resolutionPercentage / 100.0) , CGFloat(firstPoint.y) * (resolutionPercentage / 100.0) )
            
            for i in 1  ..< lines.count 
            {
                let line = lines[i] //as! LinePoint
                //print("x \(line.x)  y \(line.y)")
                CGPathAddLineToPoint(pathRef, nil, CGFloat(line.x) * (resolutionPercentage / 100.0)  , CGFloat(line.y) * (resolutionPercentage / 100.0) )
                //CGContextAddLineToPoint(context, CGFloat(line.x) * (resolutionPercentage / 100.0) * zoomScale, CGFloat(line.y) * (resolutionPercentage / 100.0) * zoomScale)
            }
            
            CGPathCloseSubpath(pathRef)
            CGContextAddPath(context, pathRef)
            
        }

        for lines in exludedRegions
        {
            //CGContextBeginPath(context)
            
            let pathRef:CGMutablePathRef = CGPathCreateMutable()
            let firstPoint = lines[0] //as! LinePoint
            CGPathMoveToPoint(pathRef,nil, CGFloat(firstPoint.x) * (resolutionPercentage / 100.0), CGFloat(firstPoint.y) * (resolutionPercentage / 100.0) )

            
            //CGContextMoveToPoint(context, CGFloat(firstPoint.x) * (resolutionPercentage / 100.0) * zoomScale, CGFloat(firstPoint.y) * (resolutionPercentage / 100.0) * zoomScale)
            for i in 1  ..< lines.count 
            {
                let line = lines[i] //as! LinePoint
                //print("x \(line.x)  y \(line.y)")
                CGPathAddLineToPoint(pathRef, nil, CGFloat(line.x) * (resolutionPercentage / 100.0) , CGFloat(line.y) * (resolutionPercentage / 100.0) )
                //CGContextAddLineToPoint(context, CGFloat(line.x) * (resolutionPercentage / 100.0) * zoomScale, CGFloat(line.y) * (resolutionPercentage / 100.0) * zoomScale)
            }
            
            //CGContextStrokePath(context)
            //CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            
            CGPathCloseSubpath(pathRef)
            CGContextAddPath(context, pathRef)
            
            //CGContextClosePath(context)
        
        }

        CGContextEOFillPath(context)
    }
    

    
    func drawTest(context:CGContext )
    {
        CGContextBeginPath(context)
        let pathRef:CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(pathRef,nil, CGFloat(0), CGFloat(0))
        CGPathAddLineToPoint(pathRef, nil, CGFloat(bounds.maxX), CGFloat(0))
        CGPathAddLineToPoint(pathRef, nil, CGFloat(bounds.maxX), CGFloat(bounds.maxY))
        CGPathAddLineToPoint(pathRef, nil, CGFloat(0), CGFloat(bounds.maxY))
        CGPathCloseSubpath(pathRef)
        CGContextAddPath(context, pathRef)
        CGContextFillPath(context)
    }
    
}
