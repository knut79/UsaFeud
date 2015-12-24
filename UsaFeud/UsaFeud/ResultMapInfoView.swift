//
//  ResultMapInfoView.swift
//  MapFeud
//
//  Created by knut on 08/12/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation

protocol ResultMapInfoViewProtocol
{
    func closeInfoView()
}
class ResultMapInfoView: UIView
{
    var insideView:UIView!
    var infoText:UILabel!
    var titleText:UILabel!
    var closeButton:UIButton!
    var imageView:UIImageView!
    var delegate:ResultMapInfoViewProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        let margin:CGFloat = 10
        

        
        insideView = UIView(frame: CGRectMake(margin, margin, self.bounds.width - (margin * 2), self.bounds.height - (margin * 2)) )
        insideView.backgroundColor = UIColor.whiteColor()
        insideView.layer.borderColor = UIColor.blueColor().CGColor
        insideView.layer.borderWidth = 1
        insideView.layer.cornerRadius = 5
        insideView.layer.masksToBounds = true
        
        closeButton = UIButton(frame: CGRectMake(insideView.bounds.width - 40, 0, 40, 40))
        closeButton.setTitle("❌", forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        titleText = UILabel(frame: CGRectMake(0, 0, insideView.bounds.width, insideView.bounds.height * 0.2))
        titleText.textAlignment = NSTextAlignment.Center
        titleText.adjustsFontSizeToFitWidth = true
        titleText.font = UIFont.boldSystemFontOfSize(20)
        insideView.addSubview(titleText)
            
        infoText = UILabel(frame: CGRectMake(insideView.bounds.width * 0.1, insideView.bounds.height * 0.2, insideView.bounds.width * 0.8, insideView.bounds.height  * 0.7))
        infoText.adjustsFontSizeToFitWidth = true
        infoText.textAlignment = NSTextAlignment.Left
        infoText.numberOfLines = 12
        infoText.font = UIFont.boldSystemFontOfSize(18)
        infoText.textColor = UIColor.blackColor()
        insideView.addSubview(infoText)
        
        insideView.addSubview(closeButton)
        
        
        self.addSubview(insideView)
        
        imageView = UIImageView(frame: CGRectZero)
        self.addSubview(imageView)
    }
    
    func setTheInfoText(place:Place)
    {
        titleText.text = place.name
        infoText.text = place.info
        imageView.alpha = 0
        for question in place.questions
        {

            if (question as! Question).tags.containsString("flag")
            {
                let flagStringImg = (question as! Question).image
                
                if let image = UIImage(named: flagStringImg)
                {
                    imageView.alpha = 1
                    imageView.image = image
                    let heightRatio = image.size.height / (self.bounds.height * 0.1)
                    let newWidth = image.size.width / heightRatio
                    imageView.frame = CGRectMake(self.bounds.width - newWidth, self.bounds.height * 0.9, newWidth, self.bounds.height * 0.1)
                }
            }
            
        }

    }
    
    func closeAction()
    {
        delegate?.closeInfoView()
    }
}