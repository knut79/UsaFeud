//
//  PlayerIconView.swift
//  MapFeud
//
//  Created by knut on 10/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class PlayerIconView: UIView {
    
    
    var imageView:UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor.whiteColor()
        
        
        let image = UIImage(named: GlobalConstants.playerSymbolName)
        imageView = UIImageView(image:image)
        imageView.frame = self.bounds
        
        self.addSubview(imageView)
        
        //tileImageView.frame = CGRectMake(CGFloat(col) * maxTileSize, CGFloat(row) * maxTileSize, image.size.width, image.size.height)
        //tileContainerView.addSubview(tileImageView)
    }
}