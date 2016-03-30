//
//  TagCheckView.swift
//  TimeIt
//
//  Created by knut on 06/08/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

protocol TagCheckItemProtocol
{
    func checkChanged()
}

class TagCheckView: UIView
{
    var checkBoxView:UIButton!
    var titleLabel:UILabel!
    var checked = true
    var tagTitle:String!
    var delegate:TagCheckItemProtocol!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, tagTitle:String, checked:Bool = true, enable:Bool = true) {
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
        
        self.addSubview(checkBoxView)
        
        self.tagTitle = tagTitle
        titleLabel = UILabel(frame: CGRectMake(checkBoxView.frame.maxX, 0, frame.width * 0.66, frame.height))
        titleLabel.userInteractionEnabled = true
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagCheckView.toggleSelect(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        titleLabel.addGestureRecognizer(singleTapGestureRecognizer)
        titleLabel.text = tagTitle
        self.addSubview(titleLabel)
        
        if enable
        {
            checkBoxView.addTarget(self, action: #selector(TagCheckView.toggleSelect(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        else
        {
            titleLabel.alpha = 0.5
            checkBoxView.alpha = 0.5
        }
        

        
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
