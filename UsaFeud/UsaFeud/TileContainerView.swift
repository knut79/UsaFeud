//
//  TileContainerView.swift
//  MapFeud
//
//  Created by knut on 08/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class TileContainerView: UIView {
    
    //var overlayDrawView:TileContainerOverlayView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(rect: CGRect)
    {
        //print("--- \(frame.width) ) - \(frame.height)")
    }

}