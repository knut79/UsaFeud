//
//  TileContainerOverlayView.swift
//  MapFeud
//
//  Created by knut on 08/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit


class ContainerOverlayLayer: CALayer {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }

    var fromPoint:CGPoint?
    var toPoint:CGPoint?
    var regions:[[LinePoint]] = []
    var resolutionPercentage:CGFloat = 100
    var zoomScale:CGFloat = 1
    let coordinateHelper = CoordinateHelper()
    

    
    var placesToDraw:[(Place,Int32,Int)] = []
    
    override func drawInContext(ctx: CGContext)
    {
        CGContextSetLineCap(ctx, CGLineCap.Round)
        CGContextSetLineJoin(ctx, CGLineJoin.Round)
        CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        
        //var included:[[LinePoint]] = []
        //self.regions = included

        drawMask(ctx)

        for item in placesToDraw
        {
            
            let insideRegion = item.2 == 1

            
            
            let rightAnswers = item.1
            var included:[[LinePoint]] = []
            //var flagStringImg = ""
            /*
            for question in item.questions
            {
                //print("right answers \((question as! Question).rightAnsw)")
                if (question as! Question).rightAnsw > 0
                {
                    rightAnswers = rightAnswers + Int((question as! Question).rightAnsw)
                }
                
                /*
                if (question as! Question).tags.containsString("flag")
                {
                    flagStringImg = (question as! Question).image
                }
                */

                
            }
            */


            
            if insideRegion
            {
                CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
            }
            else
            {
                let alphaValue = CGFloat(rightAnswers) * 0.2
                CGContextSetFillColorWithColor(ctx, UIColor.greenColor().colorWithAlphaComponent(alphaValue >= 1.0 ? 1.0 : alphaValue).CGColor)
                
                
                /*

                if flagStringImg != ""
                {

                    let ptr = UnsafePointer<Void>(Unmanaged<NSString>.passRetained(flagStringImg).toOpaque())
                    let drawPattern: CGPatternDrawPatternCallback = { (ptr, ctx) in
                        let str = Unmanaged<NSString>.fromOpaque(COpaquePointer(ptr)).takeRetainedValue()
                        let image:UIImage = UIImage(named: str as String)!
                        let imageRef:CGImageRef = image.CGImage!
                        CGContextDrawImage(ctx, CGRectMake(0, 0, 320, 44), imageRef);
                    }

                    
                    var callbacks:CGPatternCallbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern,releaseInfo: nil)
                    let patternSpace:CGColorSpaceRef = CGColorSpaceCreatePattern(nil)!
                    CGContextSetFillColorSpace(ctx, patternSpace)
                    let patternSize:CGSize = CGSizeMake(315, 44);
                    let pattern:CGPatternRef = CGPatternCreate(nil, self.bounds, CGAffineTransformIdentity, patternSize.width, patternSize.height, CGPatternTiling.ConstantSpacing, true, &callbacks)!

                    var alpha:CGFloat = 1
                    CGContextSetFillPattern(ctx, pattern, &alpha)
                    //CGPatternRelease(pattern)
                    //CGContextFillPath(c:ctx)
                    //CGContextFillRect(ctx, rect)
                }
                else
                {
                    let alphaValue = CGFloat(rightAnswers) * 0.2
                    CGContextSetFillColorWithColor(ctx, UIColor.greenColor().colorWithAlphaComponent(alphaValue >= 1.0 ? 1.0 : alphaValue).CGColor)
                }
                */
            }
            
            included.append(item.0.sortedPoints)

            drawPlace(ctx,regions: included)

        }
        
        

        //self.shouldRasterize = true
        self.shouldRasterize = false
    }
    
    func myDrawColoredPattern(info: UnsafeMutablePointer<Void>, context: CGContextRef?) -> Void {
        //draw pattern using context....
        let str = Unmanaged<NSString>.fromOpaque(COpaquePointer(info)).takeRetainedValue()
        let image:UIImage = UIImage(named: str as String)!
        let imageRef:CGImageRef = image.CGImage!
        CGContextDrawImage(context, CGRectMake(0, 0, 320, 44), imageRef);
    }
    


    
    func clearDrawing()
    {
        //self.exludedRegions = []
        self.regions = []
        self.fromPoint = nil
        self.toPoint = nil
        self.setNeedsDisplay()
    }
    
    func drawMask(context:CGContext)
    {
        //let maskImage = UIImage(named: "25MaskWater.png" )
        let useLandMask = true

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

    
    func drawPlace(context:CGContext, regions:[[LinePoint]])
    {
        for lines in regions
        {
            let pathRef:CGMutablePathRef = CGPathCreateMutable()
            let firstPoint = lines[0]
            CGPathMoveToPoint(pathRef,nil, CGFloat(firstPoint.x * 0.25), CGFloat(firstPoint.y * 0.25) )
            
            for i in 1  ..< lines.count 
            {
                let line = lines[i]
                //if i % 3 == 0
                //{
                    CGPathAddLineToPoint(pathRef, nil, CGFloat(line.x * 0.25), CGFloat(line.y * 0.25))
                //}
            }
            
            CGPathCloseSubpath(pathRef)
            CGContextAddPath(context, pathRef)
            
        }

        CGContextEOFillPath(context)
    }

    
}



