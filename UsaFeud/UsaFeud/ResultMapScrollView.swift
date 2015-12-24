//
//  ResultMapScrollView.swift
//  MapFeud
//
//  Created by knut on 06/12/15.
//  Copyright © 2015 knut. All rights reserved.
//
import Foundation
import UIKit

class ResultMapScrollView:UIView, UIScrollViewDelegate  {

    var scrollView:UIScrollView!
    var containerView:UIView!

    //let coordinateHelper = CoordinateHelper()
    let minimumResolution:Int = -2
    let maximumResolution:Int = 1
    var resolution:Int = -2
    
    var infoLabel:UILabel!
    
    var overlayDrawView:ContainerOverlayLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    init(frame: CGRect, drawBorders:Bool = false) {
        super.init(frame: frame)
        containerView = UIView(frame: CGRectZero)
        containerView.backgroundColor = UIColor.blueColor()
        containerView.autoresizesSubviews = true
        containerView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth,UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        //overlayDrawView.autoresizesSubviews = true
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, frame.width, frame.height))
        scrollView.autoresizesSubviews = true
        
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        let mapWith:CGFloat =  GlobalConstants.constMapWidth * (CGFloat(resolutionPercentage) / 100.0)
        let mapHeight:CGFloat =  GlobalConstants.constMapHeight * (CGFloat(resolutionPercentage) / 100.0)
        
        //infoLabel = UILabel(frame: <#T##CGRect#>)
        
        self.scrollView.addSubview(containerView)

        containerView.frame = CGRectMake(0, 0, mapWith, mapHeight)

        scrollView.contentSize = containerView.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = max(scaleWidth, scaleHeight)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2.9
        scrollView.zoomScale = minScale
        
        self.addSubview(scrollView)
        
        

        print("resolution : \(resolutionPercentage)")

        overlayDrawView = ContainerOverlayLayer()
        overlayDrawView!.frame = CGRectMake(0, 0, mapWith, mapHeight)
        overlayDrawView!.contentsGravity = kCAGravityCenter
        containerView.layer.addSublayer(overlayDrawView!)
        
        //overlayDrawView!.regions = placesToDraw
        overlayDrawView!.resolutionPercentage = CGFloat(resolutionPercentage)
        
        
        //overlayDrawView!.setNeedsDisplay()
        
    }
    


    func drawCountries(countries:[(Place,Int32,Int)])
    {
        overlayDrawView?.placesToDraw = countries
        overlayDrawView?.setNeedsDisplay()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
 
    /*
    var realMapCordsPoint:CGPoint!
    func setPoint(tapPoint:CGPoint)
    {
        
        var xPos = (tapPoint.x + scrollView.contentOffset.x) / scrollView.zoomScale
        var yPos = (tapPoint.y + scrollView.contentOffset.y) / scrollView.zoomScale
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        if resolutionPercentage == 25
        {
            xPos = xPos * 4
            yPos = yPos * 4
        }

        realMapCordsPoint = CGPointMake(xPos, yPos)

        
        for var i = 0 ; i < overlayDrawView!.placesToDraw.count ; i++
        {
            var place = overlayDrawView!.placesToDraw[i] as (Place,Int32,Int)
            //let insideRegion = item.2 == 1

            let insideRegion = coordinateHelper.isPointInsidePolygon(realMapCordsPoint, polygon: place.0.sortedPoints)
            place.2 = insideRegion ? 1 : 0
            print("inside \(insideRegion)")

        }

        overlayDrawView?.setNeedsDisplay()

    }
    */


    //MARK scrollview delegate
    func scrollViewDidZoom(scrollView: UIScrollView) {
        

    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
        lockable.lock()
        criticalSection()
        lockable.unlock()
    }
    
    let lock = NSLock()
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {

        //self.updateResolution()

    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
}
