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
//◻️◼️
//⚪️🔘
//◽️🔳

protocol UserViewProtocol
{
    func reloadMarks(tags:[String])
    
}

class UserScrollView: UIView , UIScrollViewDelegate, CheckItemProtocol{
    
    var checkItems:[CheckItemView]!
    var tags:[String:String]!
    var scrollView:UIScrollView!
    
    var delegate:UserViewProtocol!
    var selectedInfoLabel:UILabel!
    var itemName:String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(frame: CGRect, initialValues:[String:String] = [:], itemsName:String = "item", itemsChecked:Bool = true) {
        super.init(frame: frame)
        

        
        let itemheight:CGFloat = 40
        selectedInfoLabel = UILabel(frame: CGRectMake(0, 0, self.bounds.width, itemheight))
        selectedInfoLabel.textAlignment = NSTextAlignment.Center
        selectedInfoLabel.backgroundColor = UIColor.blueColor()
        selectedInfoLabel.textColor = UIColor.whiteColor()
        
        let scrollMarginTop:CGFloat = 6
        
        scrollView = UIScrollView(frame: CGRectMake(0, selectedInfoLabel.frame.height + scrollMarginTop, self.bounds.width, self.bounds.height - selectedInfoLabel.frame.height - scrollMarginTop))
        
        scrollView.delegate = self
        
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 5.0
        
        tags = initialValues
        checkItems = []
        
        self.itemName = itemsName
        
        var contentHeight:CGFloat = 0
        var i:CGFloat = 0
        for tagItem in tags
        {
            let newTagCheckItem = CheckItemView(frame: CGRectMake(0, itemheight * i, self.frame.width, itemheight), title: tagItem.0, value:tagItem.1 ,checked:itemsChecked)
            newTagCheckItem.delegate = self
            checkItems.append(newTagCheckItem)
            scrollView.addSubview(newTagCheckItem)
            contentHeight = newTagCheckItem.frame.maxY
            i++
        }
        let numberOfItemSelected = itemsChecked ? tags.count : 0
        selectedInfoLabel.text = "\(numberOfItemSelected) \(itemName)s selected"
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
        
        self.addSubview(selectedInfoLabel)
        
        self.addSubview(scrollView)
        
    }
    
    
    func addItem(title:String,value:String)
    {
        let itemheight:CGFloat = 40
        var contentHeight:CGFloat = 0
        
        let newTagCheckItem = CheckItemView(frame: CGRectMake(0, 0, self.frame.width, itemheight), title: title, value:value ,checked:true)
        newTagCheckItem.delegate = self
        checkItems.insert(newTagCheckItem, atIndex: 0)
        scrollView.addSubview(newTagCheckItem)
        
        contentHeight = newTagCheckItem.frame.maxY
        var itemsChecked = 0
        var i:CGFloat = 0
        for tagItem in checkItems
        {
            tagItem.frame = CGRectMake(0, itemheight * i, self.frame.width, itemheight)
            if tagItem.checked
            {
                itemsChecked += 1
            }
            contentHeight = tagItem.frame.maxY
            i++
        }
        
        selectedInfoLabel.text = "\(itemsChecked) \(itemName)s selected"
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
        
    }
    
    
    func checkChanged()
    {
        let selectedTags = getCheckedItemsValueAsArray()
        delegate.reloadMarks(selectedTags)
        
        selectedInfoLabel.text = "\(selectedTags.count) \(itemName)s selected"
    }
    
    func getCheckedItemsValueAsArray() -> [String]
    {
        var returnValue:[String] = []
        for item in checkItems
        {
            if item.checked
            {
                returnValue.append(item.value)
            }
        }
        return returnValue
    }
    
    func getAllItemsValueAsStringFormat() -> String
    {
        var returnValue:String = ""
        if checkItems.count > 0
        {
            for item in checkItems
            {
                returnValue = "\(returnValue)\(item.value),"
            }
        }
        //returnValue = dropLast(returnValue)
        return returnValue
    }
    
}
