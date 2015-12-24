//
//  ChallengeScrollView.swift
//  PlaceInTime
//
//  Created by knut on 14/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

//
//  UserScrollViewBackup.swift
//  PlaceInTime
//
//  Created by knut on 14/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

//
//  UsersScrollView.swift
//  PlaceInTime
//
//  Created by knut on 13/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

//
//  TagCheckScrollview.swift
//  TimeIt
//
//  Created by knut on 06/08/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit


protocol ChallengeViewProtocol
{
    func reloadMarks(tags:[String])
    
}

class ChallengeScrollView: UIView , UIScrollViewDelegate, RadiobuttonItemProtocol{
    
    var radiobuttonItems:[RadiobuttonItemView]!
    var items:[String:NSDictionary]!
    var scrollView:UIScrollView!
    
    var delegate:UserViewProtocol!
    var itemName:String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(frame: CGRect, initialValues:[String:NSDictionary] = [:], itemsName:String = "item") {
        super.init(frame: frame)
        
        let itemheight:CGFloat = 40

        let scrollMarginTop:CGFloat = 6
        scrollView = UIScrollView(frame: CGRectMake(0, scrollMarginTop, self.bounds.width, self.bounds.height - scrollMarginTop))
        
        scrollView.delegate = self
        
        
        items = initialValues
        radiobuttonItems = []
        
        self.itemName = itemsName
        
        var contentHeight:CGFloat = 0
        var i:CGFloat = 0
        for tagItem in items
        {
            let newTagCheckItem = RadiobuttonItemView(frame: CGRectMake(0, itemheight * i, self.frame.width, itemheight), title: tagItem.0, value:tagItem.1)
            newTagCheckItem.delegate = self
            radiobuttonItems.append(newTagCheckItem)
            scrollView.addSubview(newTagCheckItem)
            contentHeight = newTagCheckItem.frame.maxY
            i++
        }

        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 5.0
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
      
        self.addSubview(scrollView)
        
    }
    
    func addItem(title:String,value:NSDictionary)
    {
        let itemheight:CGFloat = 40
        var contentHeight:CGFloat = 0
        
        let newTagCheckItem = RadiobuttonItemView(frame: CGRectMake(0, 0, self.frame.width, itemheight), title: title, value:value )
        newTagCheckItem.delegate = self
        radiobuttonItems.append(newTagCheckItem)
        scrollView.addSubview(newTagCheckItem)
        
        contentHeight = newTagCheckItem.frame.maxY

        var i:CGFloat = 0
        for tagItem in radiobuttonItems
        {
            tagItem.frame = CGRectMake(0, itemheight * i, self.frame.width, itemheight)
            contentHeight = tagItem.frame.maxY
            i++
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
        
    }
    
    
    func uncheckAll()
    {
        
        for item in radiobuttonItems
        {
            item.uncheck()
        }

    }
    
    func getSelectedValue() -> NSDictionary?
    {
        var returnValue:NSDictionary?
        for item in radiobuttonItems
        {
            if item.checked
            {
                returnValue = item.value
            }
        }
        return returnValue
    }
    

    
    
}
