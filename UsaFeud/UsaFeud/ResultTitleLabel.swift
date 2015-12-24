//
//  ResultTitleLabel.swift
//  PlaceInTime
//
//  Created by knut on 17/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class ResultTitleLabel:UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        
        self.adjustsFontSizeToFitWidth = true
        self.backgroundColor = UIColor.blueColor()
        self.textColor = UIColor.whiteColor()
    }
}