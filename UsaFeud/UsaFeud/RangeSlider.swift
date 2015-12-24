//
//  RangeSlider.swift
//  TimeIt
//
//  Created by knut on 26/07/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import QuartzCore

enum sliderType: Int
{
    case justLower = 1
    case justUpper = 2
    case bothLowerAndUpper = 3
    case single = 4
}

class RangeSlider: UIControl {
    
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    
    var defaultTrackHighlightTintColor:UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
    
    var previousLocation = CGPoint()
    
    var typeValue: sliderType = sliderType.bothLowerAndUpper {
        didSet {
            lowerThumbLayer.hidden = false
            upperThumbLayer.hidden = false
            trackHighlightTintColor = defaultTrackHighlightTintColor
            if typeValue == sliderType.justUpper
            {
                upperValue = Double((maximumValue - minimumValue) / 2) + minimumValue
                lowerThumbLayer.hidden = true
                lowerValue = minimumValue
            }
            else if typeValue == sliderType.justLower || typeValue == sliderType.single
            {
                lowerValue = Double((maximumValue - minimumValue) / 2) + minimumValue
                upperValue = maximumValue
                upperThumbLayer.hidden = true
                if typeValue == sliderType.single
                {
                    trackHighlightTintColor = trackTintColor
                }
            }
            else
            {
                lowerValue = Double((maximumValue - minimumValue) * 0.25) + minimumValue
                upperValue = Double((maximumValue - minimumValue) * 0.75) + minimumValue
                
            }
            updateLayerFrames()
        }
    }
    
    var minimumValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var lowerValue: Double = 0.2 {
        didSet {
            /*
            if typeValue == sliderType.bothLowerAndUpper
            {
                if lowerValue >= upperValue
                {
                    lowerValue = upperValue - 1
                }
            }
            */
            updateLayerFrames()
        }
    }
    
    var upperValue: Double = 0.8 {
        didSet {
            /*
            if typeValue == sliderType.bothLowerAndUpper
            {
                if upperValue <= lowerValue
                {
                    upperValue = lowerValue + 1
                }
            }
            */
            updateLayerFrames()
        }
    }
    
    var formattedLowerValue:String
    {
        get{
            return lowerValue < 0 ? "\(Int(lowerValue * -1))BC" : "\(Int(lowerValue))"
        }
    }
    
    var formattedUpperValue:String
    {
        get{
            return upperValue < 0 ? "\(Int(upperValue * -1))BC" : "\(Int(upperValue))"
        }
    }
    
    var trackTintColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0){
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    

    
    
    func resetWindows()
    {
        updateLayerFrames()
    }
    
    
    func higlightWindows(values:(Int32?,Int32?))
    {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        CATransaction.commit()

        
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(upperThumbLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        var beginTracking = false
        // hit test the thumb layers
        if lowerThumbLayer.frame.contains(previousLocation) {
            if !upperThumbLayer.frame.contains(previousLocation) {
                // touch was unambiguously on lowerThumbLayer
                lowerThumbLayer.highlighted = true
            }
            // touch could have been on either, we'll figure out which one later
            beginTracking = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            // touch was unambiguously on upperThumbLayer
            upperThumbLayer.highlighted = true
            beginTracking = true
        }
        return beginTracking
    }
    
    func updateLayerFrames() {

        
       // upperWindowLayer.value = nil
        //lowerWindowLayer.value = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        

        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()

        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        
        if !isnan(lowerThumbCenter)
        {
            lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
                width: thumbWidth, height: thumbWidth)
            lowerThumbLayer.setNeedsDisplay()
        }
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        if !isnan(upperThumbCenter)
        {
            upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0,
                width: thumbWidth, height: thumbWidth)
            upperThumbLayer.setNeedsDisplay()
        }
        CATransaction.commit()
        

    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    /*
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            if typeValue == .bothLowerAndUpper || typeValue == sliderType.single || typeValue == .justLower
            {
                lowerValue += deltaValue
                lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            }
        } else if upperThumbLayer.highlighted {
            if typeValue == .bothLowerAndUpper || typeValue == sliderType.single || typeValue == .justUpper
            {
                upperValue += deltaValue
                upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            }
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    */
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        // determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        previousLocation = location
        // update the values
        if lowerThumbLayer.highlighted {
            if typeValue == .bothLowerAndUpper || typeValue == sliderType.single || typeValue == .justLower
            {
                lowerValue += deltaValue
                lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            }
            //lowerValue += deltaValue
            //lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if upperThumbLayer.highlighted {
            
            if typeValue == .bothLowerAndUpper || typeValue == sliderType.single || typeValue == .justUpper
            {
                upperValue += deltaValue
                upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            }
            //upperValue += deltaValue
            //upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        } else {
            // we know we're supposed to move one of the thumbs, but we don't know which yet
            if deltaValue < 0 {
                // moving left
                if lowerValue > minimumValue {
                    lowerThumbLayer.highlighted = true
                    lowerValue += deltaValue
                    lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
                }
            } else {
                // moving right
                if upperValue < maximumValue {
                    upperThumbLayer.highlighted = true
                    upperValue += deltaValue
                    upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
                }
            }
        }
        // target-action pattern: notify subscribed targets of changes
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

}
