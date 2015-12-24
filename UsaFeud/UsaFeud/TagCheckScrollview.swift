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

protocol TagCheckViewProtocol
{
    func closeTagCheckView()
    func reloadMarks(tags:[String])
    
}

class TagCheckScrollView: UIView , UIScrollViewDelegate, TagCheckItemProtocol{
    
    var tagCheckItems:[TagCheckView]!
    var tags:[String]!
    var tagsDisabled:[String]!
    var scrollView:UIScrollView!
    var closeButton:UIButton!
    var delegate:TagCheckViewProtocol!
    var selectedInfoLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tags = []
        self.tagsDisabled = []
        tagCheckItems = []
        
        
        
        closeButton = UIButton(frame: CGRectMake(frame.width - 40, 0, 40, 40))
        closeButton.setTitle("❌", forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeAction", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 2.0
        
        
        scrollView = UIScrollView(frame: CGRectMake(0, closeButton.frame.height, frame.width, frame.height - closeButton.frame.height))
        
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        
        
        tags.append("#capital")
        tags.append("#city")
        tags.append("#flag")
        tags.append("#northamerica")
        tags.append("#southamerica")
        tags.append("#america")
        tags.append("#asia")
        tags.append("#africa")
        tags.append("#europe")
        tags.append("#oceania")
        tags.append("#island")
        tags.append("#water")
        /*
        tagsDisabled.append("#northamerica")
        tagsDisabled.append("#southamerica")
        tagsDisabled.append("#america")
        tagsDisabled.append("#asia")
        tagsDisabled.append("#africa")
        tagsDisabled.append("#europe")
        tagsDisabled.append("#oceania")
        tagsDisabled.append("#island")
        tagsDisabled.append("#water")
        */
        
        let itemheight:CGFloat = 40
        
        selectedInfoLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width - closeButton.frame.width, itemheight))
        selectedInfoLabel.textAlignment = NSTextAlignment.Center
        selectedInfoLabel.text = "\(tags.count) tags selected"

        
        var contentHeight:CGFloat = 0
        var i:CGFloat = 0
        for tagItem in tags
        {
            let newTagCheckItem = TagCheckView(frame: CGRectMake(0, itemheight * i, self.frame.width, itemheight), tagTitle: tagItem)
            newTagCheckItem.delegate = self
            tagCheckItems.append(newTagCheckItem)
            scrollView.addSubview(newTagCheckItem)
            contentHeight = newTagCheckItem.frame.maxY
            i++
        }
        for tagItem in tagsDisabled
        {
            let newTagCheckItem = TagCheckView(frame: CGRectMake(0, itemheight * i, self.frame.width, itemheight), tagTitle: tagItem, checked:false, enable:false)
            newTagCheckItem.delegate = self
            tagCheckItems.append(newTagCheckItem)
            scrollView.addSubview(newTagCheckItem)
            contentHeight = newTagCheckItem.frame.maxY
            i++
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
        self.addSubview(selectedInfoLabel)
        self.addSubview(closeButton)
        
    }
    
    func unselectAllTags()
    {
        for item in tagCheckItems
        {
            item.checked = false
            item.checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        delegate.reloadMarks(getTagsAsArray())
    }
    
    func checkChanged()
    {

        let selectedTags = getTagsAsArray()
       // delegate.reloadMarks(selectedTags)
       
        selectedInfoLabel.text = "\(selectedTags.count) tags selected"

    }
    
    func getTagsAsArray() -> [String]
    {
        var returnValue:[String] = []
        for item in tagCheckItems
        {
            if item.checked
            {
                returnValue.append(item.tagTitle)
            }
        }
        return returnValue
    }
    
    func getTagsAsString() -> String
    {
        var returnValue = ""
        for item in tagCheckItems
        {
            if item.checked
            {
                returnValue += "#\(item.tagTitle)"
            }
        }
        return returnValue
    }
    
    func closeAction()
    {
        
        let selectedTags = getTagsAsArray()
        delegate.reloadMarks(selectedTags)
        
        selectedInfoLabel.text = "\(selectedTags.count) tags selected"
        
        delegate!.closeTagCheckView()

    }
}
