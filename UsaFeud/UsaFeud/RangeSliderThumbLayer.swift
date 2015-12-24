//
//  RangeSliderThumbLayer.swift
//  TimeIt
//
//  Created by knut on 26/07/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: RangeSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            
            /*
            let testFrame = bounds.rectByInsetting(dx: 6.0, dy: 3.0)
            let testRadius = testFrame.height * slider.curvaceousness / 2.0
            let testPath = UIBezierPath(roundedRect: testFrame, cornerRadius: testRadius)
            
            let testColor = UIColor.redColor()
            CGContextSetStrokeColorWithColor(ctx, testColor.CGColor)
            CGContextSetFillColorWithColor(ctx, testColor.CGColor)
            CGContextSetLineWidth(ctx, 0.5)
            CGContextAddPath(ctx, testPath.CGPath)
            CGContextStrokePath(ctx)
            CGContextFillPath(ctx)
            */
            
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill - with a subtle shadow
            let shadowColor = UIColor.grayColor()
            CGContextSetShadowWithColor(ctx, CGSize(width: 0.0, height: 1.0), 1.0, shadowColor.CGColor)
            CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            // Outline
            CGContextSetStrokeColorWithColor(ctx, shadowColor.CGColor)
            CGContextSetLineWidth(ctx, 0.5)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)
            
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
            }
        }
    }
}
