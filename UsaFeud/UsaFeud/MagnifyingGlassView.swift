//
//  MagnifyingGlassView.swift
//  MapFeud
//
//  Created by knut on 11/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit


class MagnifyingGlassView: UIView {
    
    var mapToMagnify:UIView?
    var touchPoint:CGPoint?
    var touchPointOffset:CGPoint?
    var scale:CGFloat?
    var scaleAtTouchPoint:Bool?
    let kACMagnifyingGlassDefaultOffset:CGFloat = -40
    let kACMagnifyingGlassDefaultScale:CGFloat = 2.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = self.bounds.size.width / 2
        self.layer.masksToBounds = true
        self.touchPointOffset = CGPointMake(0, kACMagnifyingGlassDefaultOffset)
        self.scale = kACMagnifyingGlassDefaultScale;
        self.mapToMagnify = nil
        self.scaleAtTouchPoint = true
        
        let image = UIImage(named: "ArrowGreen.png")
        let playerSymbol = UIImageView(image:image)
        playerSymbol.center = self.center
        playerSymbol.transform = CGAffineTransformMakeScale(0.25, 0.25)
        self.addSubview(playerSymbol)
    }
    
    func setTouchPoint(point:CGPoint)
    {
        touchPoint = point
        //self.center = CGPointMake(point.x + touchPointOffset!.x, point.y + touchPointOffset!.y);
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2 )
        CGContextScaleCTM(context, self.scale!, self.scale!)
        if let tPoint = touchPoint
        {
            let xTouchPoint = tPoint.x * -1
            var yTouchPoint = tPoint.y * -1
            yTouchPoint = yTouchPoint + (self.scaleAtTouchPoint! ? 0 : self.bounds.size.height/2)
            //xTouchPoint = xTouchPoint + self.mapToMagnify!.bounds.origin.x
            //yTouchPoint = yTouchPoint + self.mapToMagnify!.bounds.origin.y
            
            CGContextTranslateCTM(context, xTouchPoint, yTouchPoint)
            self.mapToMagnify?.layer.renderInContext(context!)
        }

        
    }
    
}