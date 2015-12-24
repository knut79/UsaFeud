//
//  ResultMapViewController.swift
//  MapFeud
//
//  Created by knut on 06/12/15.
//  Copyright © 2015 knut. All rights reserved.
//

import Foundation
import UIKit

class ResultMapViewController: UIViewController ,ResultMapInfoViewProtocol{
    
    var map:ResultMapScrollView!
    var backButton = UIButton()
    let coordinateHelper = CoordinateHelper()
    var infoView:ResultMapInfoView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapHeight = UIScreen.mainScreen().bounds.height
        
        map = ResultMapScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, mapHeight))

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapMap:")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        map.addGestureRecognizer(singleTapGestureRecognizer)

        self.view.addSubview(map)
        
        let backButtonMargin:CGFloat = 10
        backButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - (GlobalConstants.smallButtonSide * 1.5) - backButtonMargin, backButtonMargin, GlobalConstants.smallButtonSide * 1.5, GlobalConstants.smallButtonSide * 1.5)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.borderColor = UIColor.blueColor().CGColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.layer.masksToBounds = true
        backButton.setTitle("🔙", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backAction", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        
        infoView = ResultMapInfoView(frame: CGRectMake(0, 0, self.view.frame.width * 0.5, self.view.frame.height * 0.4))
        infoView?.alpha = 0
        infoView?.delegate = self
        view.addSubview(infoView!)
    }
    
    func displayInfoMessage()
    {

        let showInfo = NSUserDefaults.standardUserDefaults().boolForKey("hideResultMapInfo")
        if !showInfo
        {
            let adFreePrompt = UIAlertController(title: "Build the map",
                message: "Reveal countries by answering correct while playing challenges. \n\nTap revealed countries to get info",
                preferredStyle: .Alert)
            
            
            adFreePrompt.addAction(UIAlertAction(title: "Got it (don´t show again)",
                style: .Default,
                handler: { (action) -> Void in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hideResultMapInfo")
                    
            }))
            adFreePrompt.addAction(UIAlertAction(title: "Ok (show next time)",
                style: .Default,
                handler: { (action) -> Void in
                    
                    
            }))
            
            self.presentViewController(adFreePrompt,
                animated: true,
                completion: nil)
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        
        let countriesToDraw = getFilteredCountriesToDraw()
        map.drawCountries(countriesToDraw)
        
        if countriesToDraw.count == 0
        {
            let alert = UIAlertView(title: "No countries", message: "No countries revealed. Play challenge", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        displayInfoMessage()
        

    }
    
    func getFilteredCountriesToDraw(tappedPoint:CGPoint? = nil) -> [(Place,Int32,Int)]
    {
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        
        var filtertedPlacesToDraw:[(Place,Int32,Int)] = []
        let placesToDraw = datactrl.fetchAllCountries()
        
        
        if let countries = placesToDraw
        {
            for place in countries
            {
                var correctAnswers:Int32 = 0
                for question in place.questions
                {
                    correctAnswers = correctAnswers + (question as! Question).rightAnsw

                }
                if correctAnswers > 0
                {
                    var insideRegion = false
                    if let tp = tappedPoint
                    {
                        insideRegion = coordinateHelper.isPointInsidePolygon(tp, polygon: place.sortedPoints)
                        if insideRegion
                        {
                            showInfoView(place)
                        }
                    }
                    filtertedPlacesToDraw.append((place,correctAnswers,insideRegion ? 1 : 0))
                }
            }
        }
        
        return filtertedPlacesToDraw
    }
    
    
    func showInfoView(place:Place)
    {
        
        infoView!.setTheInfoText(place)
        infoView?.alpha = 0
        infoView?.transform = CGAffineTransformScale((infoView?.transform)!, 0.1, 0.1)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.infoView?.alpha = 1
            self.infoView?.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
        })
    }
    
    func closeInfoView()
    {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.infoView?.alpha = 0
            self.infoView?.transform = CGAffineTransformScale((self.infoView?.transform)!, 0.1, 0.1)
            }, completion: { (value: Bool) in
        })
    }
    
    
    func tapMap(gesture:UITapGestureRecognizer)
    {
        let touchLocation = gesture.locationInView(self.map)
        
        var realMapCordsPoint:CGPoint!
        var xPos = (touchLocation.x + self.map.scrollView.contentOffset.x) / self.map.scrollView.zoomScale
        var yPos = (touchLocation.y + self.map.scrollView.contentOffset.y) / self.map.scrollView.zoomScale

            xPos = xPos * 4
            yPos = yPos * 4
        
        realMapCordsPoint = CGPointMake(xPos, yPos)
        
        map.drawCountries(getFilteredCountriesToDraw(realMapCordsPoint))
        //self.map.setPoint(touchLocation)
    }
    
    func backAction()
    {
        self.performSegueWithIdentifier("segueFromResultMapToMainMenu", sender: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}