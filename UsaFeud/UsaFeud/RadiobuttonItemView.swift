//
//  TagCheckView.swift
//  TimeIt
//
//  Created by knut on 06/08/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

protocol RadiobuttonItemProtocol
{
    func uncheckAll()
}

class RadiobuttonItemView: UIView
{
    var radiobutton:UIButton!
    var titleLabel:UILabel!
    var checked = false
    var title:String!
    var value:NSDictionary!
    var delegate:RadiobuttonItemProtocol!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, title:String,value:NSDictionary) {
        super.init(frame: frame)
        
        self.checked = false
        radiobutton = UIButton(frame: CGRectMake(0, 0, frame.width * 0.33, frame.height))
        radiobutton.setTitle("⚪️", forState: UIControlState.Normal)
        radiobutton.addTarget(self, action: #selector(RadiobuttonItemView.toggleSelect(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(radiobutton)
        
        self.title = title
        self.value = value
        titleLabel = UILabel(frame: CGRectMake(radiobutton.frame.maxX, 0, frame.width * 0.66, frame.height))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.userInteractionEnabled = true
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RadiobuttonItemView.toggleSelect(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        titleLabel.addGestureRecognizer(singleTapGestureRecognizer)
        titleLabel.text = title
        self.addSubview(titleLabel)
        
    }
    
    func toggleSelect(sender:UIButton)
    {
        delegate?.uncheckAll()
        

        checked = true
        radiobutton.setTitle("🔘", forState: UIControlState.Normal)
    }
    
    func uncheck()
    {
        checked = false
        radiobutton.setTitle("⚪️", forState: UIControlState.Normal)
    }
    
}

