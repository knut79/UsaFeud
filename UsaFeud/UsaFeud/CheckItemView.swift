//
//  TagCheckView.swift
//  TimeIt
//
//  Created by knut on 06/08/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

protocol CheckItemProtocol
{
    func checkChanged()
}

class CheckItemView: UIView
{
    var checkBoxView:UIButton!
    var titleLabel:UILabel!
    var checked = true
    var title:String!
    var value:String!
    var delegate:CheckItemProtocol!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, title:String,value:String, checked:Bool = true) {
        super.init(frame: frame)
        
        self.checked = checked
        checkBoxView = UIButton(frame: CGRectMake(0, 0, frame.width * 0.33, frame.height))
        if self.checked
        {
            checkBoxView.setTitle("🔳", forState: UIControlState.Normal)
        }
        else
        {
            checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        checkBoxView.addTarget(self, action: "toggleSelect:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(checkBoxView)
        
        self.title = title
        self.value = value
        titleLabel = UILabel(frame: CGRectMake(checkBoxView.frame.maxX, 0, frame.width * 0.66, frame.height))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.userInteractionEnabled = true
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleSelect:")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        titleLabel.addGestureRecognizer(singleTapGestureRecognizer)
        titleLabel.text = title
        self.addSubview(titleLabel)
        
    }
    
    func toggleSelect(sender:UIButton)
    {
        if checked
        {
            checked = false
            checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        else
        {
            checked = true
            checkBoxView.setTitle("🔳", forState: UIControlState.Normal)
        }
        delegate?.checkChanged()
    }
    
}
