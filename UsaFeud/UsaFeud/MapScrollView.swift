//
//  MapScrollView.swift
//  MapFeud
//
//  Created by knut on 05/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit


protocol MapDelegate
{
    func finishedAnimatingAnswer(distance:Int,insidePerfectWindow:Bool,insideOkWindow:Bool)
}


class MapScrollView:UIView, UIScrollViewDelegate  {
    
    
    var tileContainerView:TileContainerView!
    var scrollView:UIScrollView!
    

    let maxTileSize:CGFloat = 256
    
    let minimumResolution:Int = -2
    let maximumResolution:Int = 1
    var resolution:Int = -2
    var playerSymbol:UIImageView!
    var drawBorders:Bool = false
    let coordinateHelper = CoordinateHelper()
    
    var pixelOkWindow:CGFloat!
    var pixelPerfectWindow:CGFloat!
    
    var delegate:MapDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    init(frame: CGRect, drawBorders:Bool = false, okWindow:CGFloat = GlobalConstants.pointOkWindowOutlineRadius, perfectWindow:CGFloat = GlobalConstants.pointPerfectWindowOutlineRadius) {
        super.init(frame: frame)
        self.drawBorders = drawBorders
        tileContainerView = TileContainerView(frame: CGRectZero)

        pixelOkWindow = okWindow
        pixelPerfectWindow = perfectWindow
        //overlayDrawView.backgroundColor = UIColor.clearColor()
        
/*
        let maskImage = UIImage(named: "25MaskLand.png" )
        let mask = CALayer()
        mask.contents = maskImage!.CGImage
        mask.frame = overlayDrawView.frame
        overlayDrawView.layer.addSublayer(mask)
        overlayDrawView.layer.mask = mask
*/
        tileContainerView.autoresizesSubviews = true
        tileContainerView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth,UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        //overlayDrawView.autoresizesSubviews = true
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, frame.width, frame.height))
        scrollView.autoresizesSubviews = true
        
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        let mapWith:CGFloat =  GlobalConstants.constMapWidth * (CGFloat(resolutionPercentage) / 100.0)
        let mapHeight:CGFloat =  GlobalConstants.constMapHeight * (CGFloat(resolutionPercentage) / 100.0)
        
        
        self.scrollView.addSubview(tileContainerView)
        
        
    
        tileContainerView.frame = CGRectMake(0, 0, mapWith, mapHeight)
        
        let image = UIImage(named: GlobalConstants.playerSymbolName)
        playerSymbol = UIImageView(image:image)
        playerSymbol.alpha = 0
        
        
        setupTileMatrixPool()
        setupTiles()
        
        
        scrollView.contentSize = tileContainerView.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = max(scaleWidth, scaleHeight)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2.9
        scrollView.zoomScale = minScale
        
        self.addSubview(scrollView)
        
        
        
    }

    var realMapCordsPlayerPoint:CGPoint!
    var realMapCordsNearestPoint:CGPoint!
    func setPoint(playerIconCenter:CGPoint)
    {
        var xPos = (playerIconCenter.x + scrollView.contentOffset.x) / scrollView.zoomScale
        var yPos = (playerIconCenter.y + scrollView.contentOffset.y) / scrollView.zoomScale
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        if resolutionPercentage == 25
        {
            xPos = xPos * 4
            yPos = yPos * 4
        }
        else if resolutionPercentage == 50
        {
            xPos = xPos * 2
            yPos = yPos * 2
        }
        realMapCordsPlayerPoint = CGPointMake(xPos, yPos)
        
        playerSymbol.removeFromSuperview()
        playerSymbol.alpha = 1
        //setPlayerIcon()

    }
    
    func setPlayerIcon()
    {
        if playerSymbol.alpha == 1
        {
            let hPrsSide = UIScreen.mainScreen().bounds.width * 0.12
            let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
            let side = hPrsSide //* CGFloat(resolutionPercentage / 100)
            playerSymbol.frame = CGRectMake(0, 0, side, side)
            
            playerSymbol.center = CGPointMake(realMapCordsPlayerPoint.x * CGFloat(resolutionPercentage / 100), realMapCordsPlayerPoint.y * CGFloat(resolutionPercentage / 100))
            playerSymbol.alpha = 0
            playerSymbol.transform = CGAffineTransformScale(playerSymbol.transform, 1.5, 1.5)
            tileContainerView.addSubview(playerSymbol)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.playerSymbol.alpha = 1
                self.playerSymbol.transform = CGAffineTransformIdentity
                }, completion: { (value: Bool) in
                    
                    
            })
        }
    }
    
    func animateAnswer(place:Place)
    {
        drawLineToPlace(place)
        
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        
        let rect = coordinateHelper.getRectOfIncludedAreas()
        
        let xPos = rect.midX * (CGFloat(resolutionPercentage) / 100.0)
        let yPos = rect.midY * (CGFloat(resolutionPercentage) / 100.0)
        let zoomRectWidth = scrollView.frame.width
        let zoomRectHeight = scrollView.frame.height
        
        print("x pos \(xPos) y pos \(yPos)")
        scrollView.zoomToRect(CGRectMake(xPos - (zoomRectWidth / 2), yPos - (zoomRectHeight / 2), zoomRectWidth , zoomRectHeight), animated: true)

        
        overlayDrawView?.fromPoint = realMapCordsPlayerPoint
        overlayDrawView?.toPoint = realMapCordsNearestPoint
        
        let placeType = PlaceType(rawValue: Int(place.type))!
        let distance:Int = coordinateHelper.getDistanceInKm(realMapCordsPlayerPoint, point2: realMapCordsNearestPoint, placeType: placeType)

        //TODO --- check if realMapCordsPlayerPoint is inside of realMapCordsNearestPoint window radius
        var insidePerfectWindow = distance <= 0
        if placeType == PlaceType.City || placeType == PlaceType.UnDefPlace || placeType == PlaceType.Mountain
        {
            insidePerfectWindow = coordinateHelper.isInsideWindowRadius(realMapCordsPlayerPoint, mapCordsNearestPoint: realMapCordsNearestPoint, radius: pixelPerfectWindow)
        }
        let insideOkWindow = coordinateHelper.isInsideWindowRadius(realMapCordsPlayerPoint, mapCordsNearestPoint: realMapCordsNearestPoint, radius: pixelOkWindow)
        
        print("inside ok window \(insideOkWindow)")
        print("inside perfect window \(insidePerfectWindow)")
        
        
        //Really messy code :( . insideX parameters is exclusivly used to handle badgeChallenges
        delegate?.finishedAnimatingAnswer(distance,insidePerfectWindow: insidePerfectWindow,insideOkWindow: insideOkWindow)
    }
    
    func drawLineToPlace(place:Place)
    {
        drawPlace(place)
        
        var excluded:[[LinePoint]] = []
        var included:[[LinePoint]] = []
        
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        
        let excludedPlaces = datactrl.fetchPlaces(place.excludePlaces)
        included.append(place.sortedPoints)
        
        let includedPlaces = datactrl.fetchPlaces(place.includePlaces)
        if let ips = includedPlaces
        {
            for item in ips
            {
                included.append(item.sortedPoints)
            }
        }
        
        if let eps = excludedPlaces
        {
            for item in eps
            {
                excluded.append(item.sortedPoints)
            }
        }
        
        realMapCordsNearestPoint = coordinateHelper.getNearestPoint(realMapCordsPlayerPoint,includedRegions: included,excludedRegions: excluded)
        
        if realMapCordsNearestPoint == nil
        {
            overlayDrawView?.fromPoint = nil
            overlayDrawView?.toPoint = nil
            print("Correct location")
        }
        else
        {
            overlayDrawView?.fromPoint = realMapCordsPlayerPoint
            overlayDrawView?.toPoint = realMapCordsNearestPoint
            overlayDrawView?.setNeedsDisplay()
        }
        
    }
    
    
    var overlayDrawView:TileContainerOverlayLayer?
    var placesToDraw:[[LinePoint]] = []
    //TODO_? handle excludedAreas for place distancewindow ( 
    var placesToExcludeDraw:[[LinePoint]] = []
    var placeTypeToDraw:PlaceType?
    func drawPlace(place:Place)
    {
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        let excludedPlaces = datactrl.fetchPlaces(place.excludePlaces)
        
        print("drawing \(place.name)")
        
        placesToDraw = []
        placesToDraw.append(place.sortedPoints)
        placesToExcludeDraw = []
        let includedPlaces = datactrl.fetchPlaces(place.includePlaces)
        if let ips = includedPlaces
        {
            for ip in ips
            {
                placesToDraw.append(ip.sortedPoints)
            }
        }
        
        placesToExcludeDraw = []
        if let eps = excludedPlaces
        {
            for ep in eps
            {
                placesToExcludeDraw.append(ep.sortedPoints)
            }
        }
        placeTypeToDraw = PlaceType(rawValue: Int(place.type))
        
        //overlayDrawView?.resolutionPercentage = resolutionPercentage
        overlayDrawView?.exludedRegions = placesToExcludeDraw
        overlayDrawView?.regions = placesToDraw
        overlayDrawView?.placeType = placeTypeToDraw

        overlayDrawView?.setNeedsDisplay()

        //overlayDrawView.drawLines(regions,excludedRegions: excludedRegions, resolutionPercentage: CGFloat(resolutionPercentage), zoomScale: scrollView.zoomScale)
    }
    
    func clearDrawing()
    {

        placesToDraw = []
        placesToExcludeDraw = []
        realMapCordsPlayerPoint = nil
        realMapCordsNearestPoint = nil
        overlayDrawView?.clearDrawing()
        
        playerSymbol.alpha = 0
        overlayDrawView?.setNeedsDisplay()
    }
    
    var tileMatrixPool = Array<Array<CALayer>>()
    
    func setupTileMatrixPool()
    {
        let maxRow:Int = Int(ceil(GlobalConstants.constMapHeight / maxTileSize))
        let maxColumn:Int = Int(ceil(GlobalConstants.constMapWidth / maxTileSize))
        
        for _ in 0..<maxRow {
            tileMatrixPool.append(Array(count:maxColumn, repeatedValue:CALayer()))
        }
    }
    func setupTiles()
    {
     

        //self.scrollView.contentOffset = CGPointZero
        //self.scrollView.contentInset = UIEdgeInsetsZero
        
        playerSymbol.removeFromSuperview()
        
        if tileContainerView.layer.sublayers?.count > 0
        {
            for layer in tileContainerView.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        
        // The resolution is stored as a power of 2, so -1 means 50%, -2 means 25%, and 0 means 100%.
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        //print("resolution : \(resolutionPercentage)")
        let mapWith:CGFloat =  GlobalConstants.constMapWidth * (CGFloat(resolutionPercentage) / 100.0)
        let mapHeight:CGFloat =  GlobalConstants.constMapHeight * (CGFloat(resolutionPercentage) / 100.0)

        
        
        let shownMinRow = Int(floor((scrollView.contentOffset.y / scrollView.zoomScale) / maxTileSize))
        let shownMinColumn = Int(floor((scrollView.contentOffset.x / scrollView.zoomScale) / maxTileSize))

        let scaledTileSize = maxTileSize * scrollView.zoomScale
        let shownMaxRow:Int = shownMinRow + Int(ceil(UIScreen.mainScreen().bounds.height / scaledTileSize))
        let shownMaxColumn:Int = shownMinColumn + Int(ceil(UIScreen.mainScreen().bounds.width / scaledTileSize))
        
        let minRow = 0
        let minColumn = 0
        let maxRow:Int = Int(ceil(mapHeight / maxTileSize))
        let maxColumn:Int = Int(ceil(mapWith / maxTileSize))
        

        for var row = minRow ; row < maxRow ; row++
        {
            for var col = minColumn ; col < maxColumn ; col++
            {
                let borderFix = drawBorders ? "border_" : ""
                //let imageName = "usa_\(Int(resolutionPercentage))_\(borderFix)\(pictureCol)_\(row).jpg"
                let imageName = "usa_\(Int(resolutionPercentage))_\(borderFix)\(col)_\(row).jpg"
                
                let tileImage = UIImage(named: imageName)

                if let image = tileImage
                {
                    let layer = CALayer()
                    layer.frame = CGRectMake(CGFloat(col) * maxTileSize, CGFloat(row) * maxTileSize, image.size.width, image.size.height)
                    layer.contents = tileImage?.CGImage
                    layer.contentsGravity = kCAGravityCenter
                    layer.hidden = true
                    if row <= shownMaxRow && row >= shownMinRow
                    {
                        if col <= shownMaxColumn && col >= shownMinColumn
                        {
                            layer.hidden = false
                            tileContainerView.layer.addSublayer(layer)
                        }
                    }

                    tileMatrixPool[row][col] = layer
                    
                    //let tileImageView = UIImageView(image:image)
                    //tileImageView.frame = CGRectMake(CGFloat(col) * maxTileSize, CGFloat(row) * maxTileSize, image.size.width, image.size.height)
                    //tileContainerView.addSubview(tileImageView)
                }
                else
                {
                    print("Did not find file \(imageName)")
                }
            }
        }

        
        //TODO ... if in resultmode
        //{
        
        overlayDrawView = TileContainerOverlayLayer()
        overlayDrawView!.frame = CGRectMake(0, 0, mapWith, mapHeight)
        overlayDrawView!.contentsGravity = kCAGravityCenter
        tileContainerView.layer.addSublayer(overlayDrawView!)
        
        overlayDrawView!.regions = placesToDraw
        overlayDrawView!.exludedRegions = placesToExcludeDraw
        overlayDrawView!.resolutionPercentage = CGFloat(resolutionPercentage)
        overlayDrawView?.fromPoint = realMapCordsPlayerPoint
        overlayDrawView?.toPoint = realMapCordsNearestPoint
        overlayDrawView?.placeType = placeTypeToDraw
        
        
        overlayDrawView!.setNeedsDisplay()
        
        //setPlayerIcon()
        //}

    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func updateResolution()
    {
        // delta will store the number of steps we should change our resolution by. If we've fallen below
        // a 25% zoom scale, for example, we should lower our resolution by 2 steps so delta will equal -2.
        // (Provided that lowering our resolution 2 steps stays within the limit imposed by minimumResolution.)
        var delta:Int = 0
        
        // check if we should decrease our resolution
        for var thisResolution = minimumResolution; thisResolution < resolution; thisResolution++
        {
            let thisDelta:Int = thisResolution - resolution
            // we decrease resolution by 1 step if the zoom scale is <= 0.5 (= 2^-1); by 2 steps if <= 0.25 (= 2^-2), and so on
            let scaleCutoff = pow(CGFloat(2), CGFloat(thisDelta))
            if self.scrollView.zoomScale <= scaleCutoff
            {
                delta = thisDelta
                break
            }
        }
        
        // if we didn't decide to decrease the resolution, see if we should increase it
        if delta == 0
        {
            for var thisResolution = maximumResolution; thisResolution > resolution; thisResolution--
            {
                let thisDelta:Int = thisResolution - resolution
                // we increase by 1 step if the zoom scale is > 1 (= 2^0); by 2 steps if > 2 (= 2^1), and so on
                let scaleCutoff:CGFloat = pow(CGFloat(2), CGFloat(thisDelta - 1))
                if self.scrollView.zoomScale > scaleCutoff
                {
                    delta = thisDelta
                    break
                }
            }
        }
        
        
        if delta != 0
        {
            resolution += delta
            
            // if we're increasing resolution by 1 step we'll multiply our zoomScale by 0.5; up 2 steps multiply by 0.25, etc
            // if we're decreasing resolution by 1 step we'll multiply our zoomScale by 2.0; down 2 steps by 4.0, etc
            let zoomFactor:CGFloat = pow(CGFloat(2), CGFloat(delta * -1))
            
            // save content offset, content size, and tileContainer size so we can restore them when we're done
            // (contentSize is not equal to containerSize when the container is smaller than the frame of the scrollView.)
            
            let contentOffset:CGPoint = self.scrollView.contentOffset
            
            let contentSize:CGSize = self.scrollView.contentSize
            let containerSize:CGSize = self.tileContainerView.frame.size

            
            // adjust all zoom values (they double as we cut resolution in half)
            self.scrollView.maximumZoomScale = self.scrollView.maximumZoomScale * zoomFactor
            self.scrollView.minimumZoomScale = self.scrollView.minimumZoomScale * zoomFactor
            self.scrollView.zoomScale = self.scrollView.zoomScale * zoomFactor
            
            // restore content offset, content size, and container size
            
            self.scrollView.contentOffset = contentOffset
            
            self.scrollView.contentSize = contentSize
            self.tileContainerView.frame = CGRectMake(0, 0, contentSize.width, containerSize.height)
            
            //[tileContainerView setFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
            
            // throw out all tiles so they'll reload at the new resolution
            //[self reloadData];
            
            self.setupTiles()

        }
    }
    

    //MARK scrollview delegate
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        /*
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        tileContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
            scrollView.contentSize.height * 0.5 + offsetY)
        */
        
        //overlayDrawView.zoomScale = scrollView.zoomScale
        //overlayDrawView.setNeedsDisplay()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let resolutionPercentage = 100 * pow(Double(2), Double(resolution))
        print("resolution : \(resolutionPercentage)")
        let mapWith:CGFloat =  GlobalConstants.constMapWidth * (CGFloat(resolutionPercentage) / 100.0)
        let mapHeight:CGFloat =  GlobalConstants.constMapHeight * (CGFloat(resolutionPercentage) / 100.0)

        
        
        let shownMinRow = Int(floor((scrollView.contentOffset.y / scrollView.zoomScale) / maxTileSize))
        let shownMinColumn = Int(floor((scrollView.contentOffset.x / scrollView.zoomScale) / maxTileSize))
        
        let scaledTileSize = maxTileSize * scrollView.zoomScale
        let shownMaxRow:Int = shownMinRow + Int(ceil(UIScreen.mainScreen().bounds.height / scaledTileSize))
        let shownMaxColumn:Int = shownMinColumn + Int(ceil(UIScreen.mainScreen().bounds.width / scaledTileSize))
        
        let minRow = 0
        let minColumn = 0
        let maxRow:Int = Int(ceil(mapHeight / maxTileSize))
        let maxColumn:Int = Int(ceil(mapWith / maxTileSize))
        for var row = minRow ; row < maxRow ; row++
        {
            for var col = minColumn ; col < maxColumn ; col++
            {

                if tileMatrixPool.count > row
                {
                    if tileMatrixPool[row].count > col
                    {
                        let layer = tileMatrixPool[row][col]
                        
                        if row <= shownMaxRow && row >= shownMinRow && col <= shownMaxColumn && col >= shownMinColumn
                        {

                            if layer.hidden
                            {
                                tileContainerView.layer.addSublayer(layer)
                                layer.hidden = false
                            }
                        }
                        else
                        {
                            layer.removeFromSuperlayer()
                            layer.hidden = true
                        }
                    }
                }
               
            }
        }
        overlayDrawView?.removeFromSuperlayer()
        
        tileContainerView.layer.addSublayer(overlayDrawView!)
        
        //tileContainerView.bringSubviewToFront(playerSymbol)
        
    }
    
    func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
        lockable.lock()
        criticalSection()
        lockable.unlock()
    }
    
    let lock = NSLock()
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        //print("zoomscale \(self.scrollView.zoomScale)")
        //print("zoomscale \(scale)")

        //synchronized(lock) {
            self.updateResolution()
        //}

    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return tileContainerView
    }
    
    
    
    
    
}