    //
//  ViewController.swift
//  TimeIt
//
//  Created by knut on 12/07/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore
import iAd
import StoreKit

class MainMenuViewController: UIViewController, TagCheckViewProtocol , ADBannerViewDelegate, HolderViewDelegate,SKProductsRequestDelegate, StatsViewProtocol {


    //payment
    var product: SKProduct?
    var productList:[SKProduct] = []
    let productIdAdFree = "MapFeudAdFree"
    let productIdAddHints = "MapFeudAddHints123"
    var productIDs:NSSet = NSSet(objects: "MapFeudAdFree","MapFeudAddHints123")
    
    //buttons
    var challengeUsersButton:MenuButton!
    var resultsButton:MenuButton!
    var practiceButton:MenuButton!
    
    var practicePlayButton:UIButton!
    var challengePlayButton:UIButton!
    
    
    var pendingChallengesButton:ChallengeButton!
    var newChallengeButton:ChallengeButton!
    var orgNewChallengeButtonCenter:CGPoint!
    var orgPendingChallengesButtonCenter:CGPoint!
    
    var selectFilterTypeButton:UIButton!
    
    var practicePlayButtonExstraLabel:UILabel!
    var challengePlayButtonExstraLabel:UILabel!
    var borderSwitch:UISwitch!
    var borderSwitchLabel:UILabel!
    var statsView:StatsView!
    
    
    var loadingDataView:UIView!
    var loadingDataLabel:UILabel!
    var datactrl:DataHandler!
    var tagsScrollViewEnableBackground:UIView!
    var tagsScrollView:TagCheckScrollView!
    
    let queue = NSOperationQueue()
    
    var updateGlobalGameStats:Bool = false
    var newGameStatsValues:(Int,Int)!

    let levelSlider = RangeSlider(frame: CGRectZero)
    var gametype:GameType!
    var tags:[String] = []
    
    var backButton:UIButton!
    var resultMapButton:UIButton!
    
    var holderView:HolderView!
    
    var numOfQuestionsForRound:Int = GlobalConstants.numberOfQuestionsForChallenge
    
    var removeAdsButton:UIButton?
    var orgRemoveAdsButtonCenter:CGPoint!
    
    var testButton:UIButton!
    
    var bannerView:ADBannerView?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterForground", name: UIApplicationWillEnterForegroundNotification, object: nil)

        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch")

        datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl


        let marginButtons:CGFloat = 10
        var buttonHeight = UIScreen.mainScreen().bounds.size.width * 0.17
        let buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.65
        
        challengeUsersButton = MenuButton(frame:CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - (buttonWidth / 2), (UIScreen.mainScreen().bounds.size.height * 0.33) + buttonHeight + marginButtons, buttonWidth, buttonHeight),title:"Challenge")
        challengeUsersButton.addTarget(self, action: "challengeAction", forControlEvents: UIControlEvents.TouchUpInside)
        let challengeBadge = NSUserDefaults.standardUserDefaults().integerForKey("challengesBadge")
        challengeUsersButton.setbadge(challengeBadge)
        challengeUsersButton.alpha = 0
        
        
        practiceButton = MenuButton(frame:CGRectMake(challengeUsersButton.frame.minX, challengeUsersButton.frame.maxY + marginButtons, buttonWidth, buttonHeight),title:"Practice")
        practiceButton.addTarget(self, action: "practiceAction", forControlEvents: UIControlEvents.TouchUpInside)
        practiceButton.alpha = 0
        
        resultsButton = MenuButton(frame:CGRectMake(practiceButton.frame.minX, practiceButton.frame.maxY + marginButtons, buttonWidth, buttonHeight),title:"Results")
        resultsButton.addTarget(self, action: "resultChallengeAction", forControlEvents: UIControlEvents.TouchUpInside)
        let resultsBadge = NSUserDefaults.standardUserDefaults().integerForKey("resultsBadge")
        resultsButton.setbadge(resultsBadge)
        resultsButton.alpha = 0

        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if !adFree
        {
            removeAdsButton = UIButton(frame: CGRectMake(0, 0, practiceButton.frame.width * 0.66,  practiceButton.frame.height))
            removeAdsButton?.addTarget(self, action: "requestBuyAdFree", forControlEvents: UIControlEvents.TouchUpInside)
            removeAdsButton?.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2,resultsButton.frame.maxY)
            removeAdsButton?.setTitle("Remove ads ☂ ", forState: UIControlState.Normal)
            removeAdsButton?.backgroundColor = UIColor.blueColor()
            removeAdsButton?.layer.cornerRadius = 3 //label.bounds.size.width / 2
            removeAdsButton?.layer.masksToBounds = true
            orgRemoveAdsButtonCenter = removeAdsButton?.center
            removeAdsButton?.alpha = 0
            self.view.addSubview(removeAdsButton!)
            
            self.canDisplayBannerAds = true
            bannerView = ADBannerView(frame: CGRectZero)
            bannerView!.center = CGPoint(x: bannerView!.center.x, y: self.view.bounds.size.height - bannerView!.frame.size.height / 2)
            self.view.addSubview(bannerView!)
            self.bannerView?.delegate = self
            self.bannerView?.hidden = false
        }
        
        let statsViewHeight = UIScreen.mainScreen().bounds.height * 0.1
        statsView = StatsView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, statsViewHeight))
        statsView.delegate = self
        self.view.addSubview(statsView)
        

        //challenge type buttons
        
       
        buttonHeight = UIScreen.mainScreen().bounds.size.height * 0.25
        let buttonMargin: CGFloat = 20.0
        
        newChallengeButton = ChallengeButton(frame:CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - ( buttonWidth / 2), (UIScreen.mainScreen().bounds.size.height / 2) -  buttonHeight - (buttonMargin / 2),buttonWidth, buttonHeight),title: "Make new")
        newChallengeButton.addTarget(self, action: "newChallengeAction", forControlEvents: UIControlEvents.TouchUpInside)
        newChallengeButton.alpha = 0
        
        pendingChallengesButton = ChallengeButton(frame:CGRectMake(self.newChallengeButton.frame.minX, self.newChallengeButton.frame.maxY + buttonMargin, buttonWidth, buttonHeight),title: "Take pending")
        pendingChallengesButton.addTarget(self, action: "pendingChallengesAction", forControlEvents: UIControlEvents.TouchUpInside)
        pendingChallengesButton.setbadge(challengeBadge)
        pendingChallengesButton.alpha = 0
        
        orgNewChallengeButtonCenter = newChallengeButton.center
        orgPendingChallengesButtonCenter = pendingChallengesButton.center
        
        practicePlayButton = UIButton(frame:CGRectZero)
        practicePlayButton.setTitle("Practice", forState: UIControlState.Normal)
        practicePlayButton.addTarget(self, action: "playPracticeAction", forControlEvents: UIControlEvents.TouchUpInside)
        practicePlayButton.backgroundColor = UIColor.blueColor()
        practicePlayButton.layer.cornerRadius = 5
        practicePlayButton.layer.masksToBounds = true
        
        challengePlayButton = UIButton(frame:CGRectZero)
        challengePlayButton.setTitle("New challenge\n\(numOfQuestionsForRound) questions", forState: UIControlState.Normal)
        challengePlayButton.titleLabel?.textAlignment = NSTextAlignment.Center
        challengePlayButton.titleLabel!.numberOfLines = 2
        challengePlayButton.addTarget(self, action: "playNewChallengeAction", forControlEvents: UIControlEvents.TouchUpInside)
        challengePlayButton.backgroundColor = UIColor.blueColor()
        challengePlayButton.layer.cornerRadius = 5
        challengePlayButton.layer.masksToBounds = true

        challengePlayButtonExstraLabel = UILabel(frame:CGRectZero)
        challengePlayButtonExstraLabel.backgroundColor = challengePlayButton.backgroundColor?.colorWithAlphaComponent(0)
        challengePlayButtonExstraLabel.textColor = UIColor.whiteColor()
        challengePlayButtonExstraLabel.font = UIFont.systemFontOfSize(12)
        challengePlayButtonExstraLabel.textAlignment = NSTextAlignment.Center
        challengePlayButton.addSubview(challengePlayButtonExstraLabel)
        
        
        
        practicePlayButtonExstraLabel = UILabel(frame:CGRectZero)
        practicePlayButtonExstraLabel.backgroundColor = practicePlayButton.backgroundColor?.colorWithAlphaComponent(0)
        practicePlayButtonExstraLabel.textColor = UIColor.whiteColor()
        practicePlayButtonExstraLabel.font = UIFont.systemFontOfSize(12)
        practicePlayButtonExstraLabel.textAlignment = NSTextAlignment.Center
        practicePlayButton.addSubview(practicePlayButtonExstraLabel)

        
        levelSlider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
        levelSlider.curvaceousness = 0.0
        levelSlider.maximumValue = Double(GlobalConstants.maxLevel) + 0.5
        levelSlider.minimumValue = Double(GlobalConstants.minLevel)
        levelSlider.typeValue = sliderType.bothLowerAndUpper
        levelSlider.lowerValue = 1
        levelSlider.upperValue = 2

        
        borderSwitch = UISwitch(frame: CGRectZero)
        borderSwitch.on = false
        borderSwitch.addTarget(self, action: "borderStateChanged:", forControlEvents: UIControlEvents.TouchUpInside)
        borderSwitch.alpha = 0
        
        borderSwitchLabel = UILabel(frame: CGRectZero)
        borderSwitchLabel.font = UIFont.boldSystemFontOfSize(24)
        borderSwitchLabel.adjustsFontSizeToFitWidth = true
        borderSwitchLabel.textAlignment = NSTextAlignment.Center
        borderSwitchLabel.text = "No country borders❗️"
        borderSwitchLabel.alpha = 0

        
        selectFilterTypeButton = UIButton(frame: CGRectZero)
        selectFilterTypeButton.setTitle("📋", forState: UIControlState.Normal)
        selectFilterTypeButton.layer.borderColor = UIColor.blueColor().CGColor
        selectFilterTypeButton.addTarget(self, action: "openFilterList", forControlEvents: UIControlEvents.TouchUpInside)
        selectFilterTypeButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        
        let backButtonMargin:CGFloat = 10
        backButton = UIButton(frame: CGRectZero)
        backButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - GlobalConstants.smallButtonSide - backButtonMargin, self.statsView.frame.maxY + backButtonMargin, GlobalConstants.smallButtonSide, GlobalConstants.smallButtonSide)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.borderColor = UIColor.blueColor().CGColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.layer.masksToBounds = true
        backButton.setTitle("🔙", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backAction", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        
        resultMapButton = UIButton(frame: CGRectZero)
        resultMapButton.frame = CGRectMake(backButtonMargin, self.statsView.frame.maxY + backButtonMargin, GlobalConstants.smallButtonSide, GlobalConstants.smallButtonSide)
        resultMapButton.backgroundColor = UIColor.whiteColor()
        resultMapButton.layer.borderColor = UIColor.blueColor().CGColor
        resultMapButton.layer.borderWidth = 3
        resultMapButton.layer.cornerRadius = resultMapButton.frame.height / 2
        resultMapButton.layer.masksToBounds = true
        resultMapButton.setTitle("🌐", forState: UIControlState.Normal)
        resultMapButton.addTarget(self, action: "resultMapAction", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(resultMapButton)
 
        practicePlayButton.alpha = 0
        challengePlayButton.alpha = 0
        levelSlider.alpha = 0
        selectFilterTypeButton.alpha = 0
        backButton.alpha = 0
        resultMapButton.alpha = 0

        self.view.addSubview(challengeUsersButton)
        self.view.addSubview(practiceButton)
        self.view.addSubview(resultsButton)
        
        self.view.addSubview(newChallengeButton)
        self.view.addSubview(pendingChallengesButton)

        
        self.view.addSubview(practicePlayButton)
        self.view.addSubview(challengePlayButton)
        self.view.addSubview(levelSlider)
        self.view.addSubview(selectFilterTypeButton)
        self.view.addSubview(borderSwitchLabel)
        self.view.addSubview(borderSwitch)
        
        
        setupCheckboxView()
        
        
        setupFirstLevelMenu()
        setupPlayButton()
        closeTagCheckView()
        
        if firstLaunch
        {

           if Int(datactrl.dataPopulatedValue as! NSNumber) <= 0
            {
                loadingDataView = UIView(frame: self.view.frame)
                loadingDataView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.7)
                loadingDataLabel = UILabel(frame: CGRectMake(loadingDataView.frame.midX - 100, loadingDataView.frame.midY - 25, 200, 50))
                loadingDataLabel.text = "Loading data.."
                loadingDataLabel.textAlignment = NSTextAlignment.Center
                loadingDataLabel.backgroundColor = UIColor.blueColor()
                loadingDataView.addSubview(loadingDataLabel)
                self.view.addSubview(loadingDataView)
                
                let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
                pulseAnimation.duration = 0.3
                pulseAnimation.toValue = NSNumber(float: 0.3)
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = 100
                pulseAnimation.delegate = self
                loadingDataLabel.layer.addAnimation(pulseAnimation, forKey: "asd")
            }
        }
        else
        {
            allowRotate = true
            self.challengeUsersButton.alpha = 1
            self.practiceButton.alpha = 1
            self.resultsButton.alpha = 1
            self.removeAdsButton?.alpha = 1
            self.resultMapButton.alpha = 1
            
            requestProductData()
            //setupAfterPopulateData()
        }
        
        updateBadges()

        //setupAfterPopulateData()
        
        /*
        testButton = UIButton(frame:CGRectMake(resultsButton.frame.minX, resultsButton.frame.maxY + marginButtons, buttonWidth, buttonHeight))
        testButton.setTitle("TEST", forState: UIControlState.Normal)
        testButton.addTarget(self, action: "testAction2", forControlEvents: UIControlEvents.TouchUpInside)
        testButton.backgroundColor = UIColor.blueColor()
        testButton.alpha = 1
        view.addSubview(testButton)
        */

    }
    
    func enterForground()
    {
        updateBadges()
    }
    
    func updateBadges()
    {
        /*
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        // do some task
        dispatch_async(dispatch_get_main_queue()) {
        // update some UI
        }
        }
        */
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.recieveNumberOfResultsNotDownloaded()
        }
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.recieveNumberOfPendingChallenges()
        }
    }
    
    func borderStateChanged(switchState: UISwitch) {
        if switchState.on {
            borderSwitchLabel.text = "Country borders"
        } else {
            borderSwitchLabel.text = "No country borders"
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        bannerView?.delegate = nil
        bannerView?.removeFromSuperview()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {

        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch")
        if firstLaunch
        {
            holderView = HolderView(frame: view.bounds)
            holderView.delegate = self
            view.addSubview(holderView)
            holderView.startAnimation()

            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstlaunch")
        }
        


    }
    
    func loadScreenFinished() {
        
        self.view.backgroundColor = UIColor.whiteColor()

        holderView.hidden = true
        allowRotate = true
        
        challengeUsersButton.transform = CGAffineTransformScale(challengeUsersButton.transform, 0.1, 0.1)
        practiceButton.transform = CGAffineTransformScale(practiceButton.transform, 0.1, 0.1)
        resultsButton.transform = CGAffineTransformScale(resultsButton.transform, 0.1, 0.1)
        removeAdsButton?.transform = CGAffineTransformScale(removeAdsButton!.transform, 0.1, 0.1)
        resultMapButton?.transform = CGAffineTransformScale(resultMapButton!.transform, 0.1, 0.1)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.challengeUsersButton.alpha = 1
            self.practiceButton.alpha = 1
            self.resultsButton.alpha = 1
            self.removeAdsButton?.alpha = 1
            self.resultMapButton?.alpha = 1
            self.challengeUsersButton.transform = CGAffineTransformIdentity
            self.practiceButton.transform = CGAffineTransformIdentity
            self.resultsButton.transform = CGAffineTransformIdentity
            self.removeAdsButton?.transform = CGAffineTransformIdentity
            self.resultMapButton?.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                self.view.backgroundColor = UIColor.whiteColor()
                self.requestProductData()
                self.populateDataIfNeeded()
        })
        
        
        //test _?
        /*
        datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        datactrl.adFreeValue = 1
        datactrl.timeBounusValue = 0
        datactrl.hintsValue = 10
    */
        //datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        //datactrl.addRecordToGameResults("22,newest,234,1-3 no bord from Elizabethhhh,,4321")
        //datactrl.addRecordToGameResults("222,Hans pettersen,444,abc,,1111")
        //datactrl.addRecordToGameResults("222,per,444,abc,,4321")
      
        //datactrl.saveGameData()
        //datactrl.loadGameData()
        
    
        //NSUserDefaults.standardUserDefaults().setBool(false, forKey: "adFree")
        //NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "timeBonus")
        //NSUserDefaults.standardUserDefaults().synchronize()
        
        //end test
    }
    
    func populateDataIfNeeded()
    {
        if Int(datactrl.dataPopulatedValue as! NSNumber) <= 0
        {
            
            datactrl.populateData({ () in
                
                
                self.loadingDataView.alpha = 0
                self.loadingDataView.layer.removeAllAnimations()
            })
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {

    }
    
    func setupFirstLevelMenu()
    {
        let marginButtons:CGFloat = 10
        var buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.17
        let buttonHeight = buttonWidth

        buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.65
        challengeUsersButton.frame = CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - (buttonWidth / 2), UIScreen.mainScreen().bounds.size.height * 0.33, buttonWidth, buttonHeight)
        challengeUsersButton.orgCenter = challengeUsersButton.center
        practiceButton.frame = CGRectMake(challengeUsersButton.frame.minX, challengeUsersButton.frame.maxY + marginButtons, buttonWidth, buttonHeight)
        practiceButton.orgCenter = practiceButton.center
        resultsButton.frame = CGRectMake(challengeUsersButton.frame.minX, practiceButton.frame.maxY + marginButtons, buttonWidth, buttonHeight)
        resultsButton.orgCenter = resultsButton.center
    }
    
    func setupPlayButton()
    {
        let margin: CGFloat = 20.0
        let sliderAndFilterbuttonHeight:CGFloat = 31.0

        let playbuttonWidth = self.practiceButton.frame.maxX - self.challengeUsersButton.frame.minX
        let playbuttonHeight = self.resultsButton.frame.maxY - self.challengeUsersButton.frame.minY - sliderAndFilterbuttonHeight - margin

        practicePlayButton.frame = CGRectMake(self.challengeUsersButton.frame.minX, self.challengeUsersButton.frame.minY,playbuttonWidth, playbuttonHeight)
        challengePlayButton.frame = practicePlayButton.frame
        
        print("challengePlayButton.frame \(challengePlayButton.frame.width) \(challengePlayButton.frame.height)")
        print("practicePlayButton.frame \(practicePlayButton.frame.width) \(practicePlayButton.frame.height)")
        
        let marginSlider: CGFloat = practicePlayButton.frame.minX
        
        practicePlayButtonExstraLabel.frame = CGRectMake(0, practicePlayButton.frame.height * 0.7   , practicePlayButton.frame.width, practicePlayButton.frame.height * 0.15)
        practicePlayButtonExstraLabel.text = "Level \(Int(levelSlider.lowerValue)) - \(sliderUpperLevelText())"
        
        challengePlayButtonExstraLabel.frame = CGRectMake(0, challengePlayButton.frame.height * 0.7   , practicePlayButton.frame.width, challengePlayButton.frame.height * 0.15)
        challengePlayButtonExstraLabel.text = "Level \(Int(levelSlider.lowerValue)) - \(sliderUpperLevelText())"

        
        levelSlider.frame = CGRect(x:  marginSlider, y: practicePlayButton.frame.maxY  + margin, width: UIScreen.mainScreen().bounds.size.width - (marginSlider * 2) - (practicePlayButton.frame.width * 0.2), height: sliderAndFilterbuttonHeight)
        
        selectFilterTypeButton.frame = CGRectMake(levelSlider.frame.maxX, practicePlayButton.frame.maxY + margin, UIScreen.mainScreen().bounds.size.width * 0.2, levelSlider.frame.height)
        
        let borderElementWidth1 = practicePlayButton.frame.width * 0.6
        let borderElementWidth2 = practicePlayButton.frame.width * 0.33
        borderSwitchLabel.frame = CGRectMake(levelSlider.frame.minX, levelSlider.frame.maxY + margin, borderElementWidth1, levelSlider.frame.height)
        borderSwitch.frame = CGRectMake(practicePlayButton.frame.maxX - borderElementWidth2, levelSlider.frame.maxY + margin, borderElementWidth2, levelSlider.frame.height)
        

    }
    
    func setupChallengeTypeButtons()
    {
        let buttonMargin: CGFloat = 20.0
        var buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.17
        var buttonHeight = buttonWidth

        buttonWidth = UIScreen.mainScreen().bounds.size.width * 0.65
        buttonHeight = UIScreen.mainScreen().bounds.size.height * 0.35
        newChallengeButton.frame = CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - ( buttonWidth / 2), UIScreen.mainScreen().bounds.size.height * 0.15,buttonWidth, buttonHeight)
        pendingChallengesButton.frame = CGRectMake(self.newChallengeButton.frame.minX, self.newChallengeButton.frame.maxY + buttonMargin, buttonWidth, buttonHeight)
    }
    
    func sliderUpperLevelText() -> String
    {
        return Int(levelSlider.upperValue) > 4 ? "Ridiculous" : "\(Int(levelSlider.upperValue))"
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rangeSliderValueChanged(slider: RangeSlider) {
        
        if Int(slider.lowerValue) == Int(slider.upperValue)
        {
            let text = "Level \(sliderUpperLevelText())"
            practicePlayButtonExstraLabel.text = text
            challengePlayButtonExstraLabel.text = text
        }
        else
        {
            let text = "Level \(Int(slider.lowerValue)) - \(sliderUpperLevelText())"
            practicePlayButtonExstraLabel.text = text
            challengePlayButtonExstraLabel.text = text
        }
    }
    
    func backAction()
    {
        backButton.alpha = 0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.challengeUsersButton.center = self.challengeUsersButton.orgCenter
            self.challengeUsersButton.alpha = 1
            self.challengeUsersButton.transform = CGAffineTransformIdentity
            self.practiceButton.center = self.practiceButton.orgCenter
            self.practiceButton.alpha = 1
            self.practiceButton.transform = CGAffineTransformIdentity
            self.resultsButton.center = self.resultsButton.orgCenter
            self.resultsButton.alpha = 1
            self.resultsButton.transform = CGAffineTransformIdentity
            self.removeAdsButton?.center = self.orgRemoveAdsButtonCenter
            self.removeAdsButton?.alpha = 1
            self.removeAdsButton?.transform = CGAffineTransformIdentity
            self.resultMapButton?.alpha = 1
            self.resultMapButton?.transform = CGAffineTransformIdentity
            
            self.practicePlayButton.alpha = 0
            self.levelSlider.alpha = 0
            self.selectFilterTypeButton.alpha = 0
            self.borderSwitchLabel.alpha = 0
            self.borderSwitch.alpha = 0
            
            self.newChallengeButton.alpha = 0
            self.pendingChallengesButton.alpha = 0
            self.newChallengeButton.center = self.orgNewChallengeButtonCenter
            self.pendingChallengesButton.center = self.orgPendingChallengesButtonCenter
                
            self.challengePlayButton.alpha = 0
            }, completion: { (value: Bool) in
                
                
        })
    }
    
    func resultMapAction()
    {
        self.performSegueWithIdentifier("segueFromMainMenuToResultMap", sender: nil)
    }
    
    func playPracticeAction()
    {
        datactrl.fetchData(self.tags,fromLevel:Int(levelSlider.lowerValue),toLevel: Int(levelSlider.upperValue))
        datactrl.shuffleQuestions()
        datactrl.orderOnUsed()
        
        gametype = GameType.training
        self.performSegueWithIdentifier("segueFromMainMenuToPlay", sender: nil)
    }

    
    func practiceAction()
    {
        
        self.practicePlayButton.alpha = 0
        self.practicePlayButton.transform = CGAffineTransformScale(self.practicePlayButton.transform, 0.1, 0.1)
        self.levelSlider.alpha = 0
        self.levelSlider.transform = CGAffineTransformScale(self.levelSlider.transform, 0.1, 0.1)
        self.selectFilterTypeButton.alpha = 0
        self.selectFilterTypeButton.transform = CGAffineTransformScale(self.selectFilterTypeButton.transform, 0.1, 0.1)
        self.borderSwitchLabel.alpha = 0
        self.borderSwitchLabel.transform = CGAffineTransformScale(self.borderSwitchLabel.transform, 0.1, 0.1)
        self.borderSwitch.alpha = 0
        self.borderSwitch.transform = CGAffineTransformScale(self.borderSwitchLabel.transform, 0.1, 0.1)
        
        let centerScreen = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.challengeUsersButton.center = centerScreen
            self.challengeUsersButton.transform = CGAffineTransformScale(self.challengeUsersButton.transform, 0.1, 0.1)
            self.practiceButton.center = centerScreen
            self.practiceButton.transform = CGAffineTransformScale(self.practiceButton.transform, 0.1, 0.1)
            self.resultsButton.center = centerScreen
            self.resultsButton.transform = CGAffineTransformScale(self.resultsButton.transform, 0.1, 0.1)
            self.removeAdsButton?.center = centerScreen
            self.removeAdsButton?.transform = CGAffineTransformScale(self.removeAdsButton!.transform, 0.1, 0.1)
            self.resultMapButton?.transform = CGAffineTransformScale(self.resultMapButton!.transform, 0.1, 0.1)
            
            self.backButton.alpha = 1
            
            }, completion: { (value: Bool) in
                
                self.challengeUsersButton.alpha = 0
                self.practiceButton.alpha = 0
                self.resultsButton.alpha = 0
                self.removeAdsButton?.alpha = 0
                self.resultMapButton.alpha = 0
                
                self.practicePlayButton.alpha = 1
                self.levelSlider.alpha = 1
                self.selectFilterTypeButton.alpha = 1
                
                self.borderSwitchLabel.alpha = 1
                self.borderSwitch.alpha = 1
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.practicePlayButton.transform = CGAffineTransformIdentity
                    self.levelSlider.transform = CGAffineTransformIdentity
                    self.selectFilterTypeButton.transform = CGAffineTransformIdentity
                    self.borderSwitchLabel.transform = CGAffineTransformIdentity
                    self.borderSwitch.transform = CGAffineTransformIdentity
                    }, completion: { (value: Bool) in
                        
                        
                })
        })
    }
    
    func newChallengeAction()
    {


        self.challengePlayButton.alpha = 0
        self.challengePlayButton.transform = CGAffineTransformScale(self.challengePlayButton.transform, 0.1, 0.1)
        self.levelSlider.alpha = 0
        self.levelSlider.transform = CGAffineTransformScale(self.levelSlider.transform, 0.1, 0.1)
        self.borderSwitchLabel.alpha = 0
        self.borderSwitchLabel.transform = CGAffineTransformScale(self.borderSwitchLabel.transform, 0.1, 0.1)
        self.borderSwitch.alpha = 0
        self.borderSwitch.transform = CGAffineTransformScale(self.borderSwitchLabel.transform, 0.1, 0.1)
        
        let centerScreen = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.newChallengeButton.center = centerScreen
            self.newChallengeButton.transform = CGAffineTransformScale(self.challengeUsersButton.transform, 0.1, 0.1)
            self.pendingChallengesButton.center = centerScreen
            self.pendingChallengesButton.transform = CGAffineTransformScale(self.pendingChallengesButton.transform, 0.1, 0.1)
            
            }, completion: { (value: Bool) in
                
                self.newChallengeButton.alpha = 0
                self.pendingChallengesButton.alpha = 0
                
                self.challengePlayButton.alpha = 1
                self.levelSlider.alpha = 1
                //self.selectFilterTypeButton.alpha = 1
                
                self.borderSwitchLabel.alpha = 1
                self.borderSwitch.alpha = 1
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.challengePlayButton.transform = CGAffineTransformIdentity
                    self.levelSlider.transform = CGAffineTransformIdentity
                    //self.selectFilterTypeButton.transform = CGAffineTransformIdentity
                    self.borderSwitchLabel.transform = CGAffineTransformIdentity
                    self.borderSwitch.transform = CGAffineTransformIdentity
                    }, completion: { (value: Bool) in
                        
                })
        })
    }
    
    func playNewChallengeAction()
    {
        datactrl.fetchData(self.tags,fromLevel:Int(levelSlider.lowerValue),toLevel: Int(levelSlider.upperValue))
        datactrl.shuffleQuestions()
        datactrl.orderOnUsed()
        
        gametype = GameType.makingChallenge
        self.performSegueWithIdentifier("segueFromMainMenuToChallenge", sender: nil)
    }
    
    func pendingChallengesAction()
    {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "challengesBadge")
        gametype = GameType.takingChallenge
        self.performSegueWithIdentifier("segueFromMainMenuToChallenge", sender: nil)
    }
    
    func challengeAction()
    {
        self.newChallengeButton.transform = CGAffineTransformScale(self.newChallengeButton.transform, 0.1, 0.1)
        self.pendingChallengesButton.transform = CGAffineTransformScale(self.pendingChallengesButton.transform, 0.1, 0.1)
        
        let centerScreen = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        UIView.animateWithDuration(0.2, animations: { () -> Void in

            self.backButton.alpha = 1
            
            self.challengeUsersButton.center = centerScreen
            self.challengeUsersButton.transform = CGAffineTransformScale(self.challengeUsersButton.transform, 0.1, 0.1)
            self.practiceButton.center = centerScreen
            self.practiceButton.transform = CGAffineTransformScale(self.practiceButton.transform, 0.1, 0.1)
            self.resultsButton.center = centerScreen
            self.resultsButton.transform = CGAffineTransformScale(self.resultsButton.transform, 0.1, 0.1)
            self.removeAdsButton?.transform = CGAffineTransformScale(self.removeAdsButton!.transform, 0.1, 0.1)
            
            }, completion: { (value: Bool) in
                
                self.challengeUsersButton.alpha = 0
                self.practiceButton.alpha = 0
                self.resultsButton.alpha = 0
                self.removeAdsButton?.alpha = 0
                self.newChallengeButton.alpha = 1
                self.pendingChallengesButton.alpha = 1
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    self.newChallengeButton.transform = CGAffineTransformIdentity
                    self.pendingChallengesButton.transform = CGAffineTransformIdentity
                    }, completion: { (value: Bool) in
                        print("test4 \(self.pendingChallengesButton.frame.width) \(self.pendingChallengesButton.frame.height)")
                })
        })

    }
    
    func resultChallengeAction()
    {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "resultsBadge")
        self.performSegueWithIdentifier("segueFromMainMenuToChallengeResults", sender: nil)
    }
    
    func resultTimelineAction()
    {
        self.performSegueWithIdentifier("segueFromMainMenuToTimeline", sender: nil)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if (segue.identifier == "segueFromMainMenuToPlay") {
            let svc = segue!.destinationViewController as! PlayViewController
            svc.gametype = gametype
            svc.drawBorders = borderSwitch.on
        }
        
        if (segue.identifier == "segueFromMainMenuToChallenge") {
            let svc = segue!.destinationViewController as! ChallengeViewController
            svc.passingLevelLow = Int(levelSlider.lowerValue)
            svc.passingLevelHigh = Int(levelSlider.upperValue)
            svc.passingTags = self.tags
            svc.numOfQuestionsForRound = self.numOfQuestionsForRound
            svc.gametype = self.gametype
            svc.drawBorders = borderSwitch.on
        }
    }
    
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        self.bannerView?.hidden = adFree
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        self.bannerView?.hidden = adFree
    }

    //MARK: TagCheckViewProtocol
    var listClosed = true
    func closeTagCheckView()
    {
        if listClosed
        {
            return
        }
        
        if self.tags.count < 1
        {
            let alert = UIAlertView(title: "Pick 1", message: "Select at least 1 tags", delegate: nil, cancelButtonTitle: "OK")
            alert.show()

        }
        else
        {

            let rightLocation = tagsScrollView.center
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.tagsScrollView.transform = CGAffineTransformScale(self.tagsScrollView.transform, 0.1, 0.1)
                
                self.tagsScrollView.center = self.selectFilterTypeButton.center
                }, completion: { (value: Bool) in
                    self.tagsScrollView.transform = CGAffineTransformScale(self.tagsScrollView.transform, 0.1, 0.1)
                    self.tagsScrollView.alpha = 0
                    self.tagsScrollView.center = rightLocation
                    self.listClosed = true
                    self.tagsScrollViewEnableBackground.alpha = 0
            })
        }
    }
    
    func reloadMarks(tags:[String])
    {
        self.tags = tags
    }
    
    func setupCheckboxView()
    {
        let bannerViewHeight = bannerView != nil ? bannerView!.frame.height : 0
        tagsScrollViewEnableBackground = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - bannerViewHeight))
        tagsScrollViewEnableBackground.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        tagsScrollViewEnableBackground.alpha = 0
        let scrollViewWidth = UIScreen.mainScreen().bounds.size.width * 0.6

        tagsScrollView = TagCheckScrollView(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - (scrollViewWidth / 2) , UIScreen.mainScreen().bounds.size.height / 4, scrollViewWidth, UIScreen.mainScreen().bounds.size.height / 2))
        tagsScrollView.delegate = self
        tagsScrollView.alpha = 0
        tagsScrollViewEnableBackground.addSubview(tagsScrollView!)
        view.addSubview(tagsScrollViewEnableBackground)
    }
    
    func openFilterList()
    {
        let rightLocation = tagsScrollView.center
        tagsScrollView.transform = CGAffineTransformScale(tagsScrollView.transform, 0.1, 0.1)
        self.tagsScrollView.alpha = 1
        tagsScrollView.center = selectFilterTypeButton.center
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tagsScrollViewEnableBackground.alpha = 1
            self.tagsScrollView.transform = CGAffineTransformIdentity
            
            self.tagsScrollView.center = rightLocation
            }, completion: { (value: Bool) in
                self.tagsScrollView.transform = CGAffineTransformIdentity
                self.tagsScrollView.alpha = 1
                self.tagsScrollView.center = rightLocation
                self.listClosed = false
        })
        
    }
    
    //MARK: Buy
    
    func requestBuyAdFree()
    {
        let adFreePrompt = UIAlertController(title: "Remove ads",
            message: "",
            preferredStyle: .Alert)
        
        
        adFreePrompt.addAction(UIAlertAction(title: "Buy",
            style: .Default,
            handler: { (action) -> Void in
                self.buyAdFree()
        }))
        adFreePrompt.addAction(UIAlertAction(title: "Restore purchase",
            style: .Default,
            handler: { (action) -> Void in
                
                self.buyAdFree()
        }))
        
        self.presentViewController(adFreePrompt,
            animated: true,
            completion: nil)
    }
    
    func buyAdFree()
    {

        for p in productList
        {
            let productId = p.productIdentifier
            if productId == productIdAdFree
            {
                product = p
                buyProductAction()
                break
            }
        }
    }
    
    func requestBuyHints()
    {
        let adFreePrompt = UIAlertController(title: "Buy hints",
            message: "Buy \(GlobalConstants.numberOfHintsPrBuy) hints. In addition to beeing used as hints\n they can also be used to expand time",
            preferredStyle: .Alert)
        
        
        adFreePrompt.addAction(UIAlertAction(title: "Buy",
            style: .Default,
            handler: { (action) -> Void in
                self.buyHints()
        }))
        
        self.presentViewController(adFreePrompt,
            animated: true,
            completion: nil)
    }
    
    func buyHints()
    {
        for p in productList
        {
            let productId = p.productIdentifier
            if productId == productIdAddHints
            {
                product = p
                buyProductAction()
                break
            }
        }

    }
    
    func requestBuyTime()
    {
        var timeBonus = NSUserDefaults.standardUserDefaults().integerForKey("timeBonus")
        if timeBonus  >= 10
        {
            let maxTimePrompt = UIAlertController(title: "Max time",
                message: "Time is streched far enough",
                preferredStyle: .Alert)
            maxTimePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    
            }))
            self.presentViewController(maxTimePrompt,
                animated: true,
                completion: nil)
        }
        else
        {
            let expandTimePrompt = UIAlertController(title: "Expand time",
                message: "Use \(GlobalConstants.hintCostForTimeBonus) hints and expand time by 15%",
                preferredStyle: .Alert)
            
            
            expandTimePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    var hints = NSUserDefaults.standardUserDefaults().integerForKey("hintsLeftOnAccount")
                    if hints >= GlobalConstants.hintCostForTimeBonus
                    {
                        
                        timeBonus++
                        hints = hints - GlobalConstants.hintCostForTimeBonus
                        self.statsView.timeButton.sTime(timeBonus)
                        self.statsView.hintsButton.sHints(hints)
                        NSUserDefaults.standardUserDefaults().setInteger(hints, forKey: "hintsLeftOnAccount")
                        NSUserDefaults.standardUserDefaults().setInteger(timeBonus, forKey: "timeBonus")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.datactrl.hintsValue = hints
                        self.datactrl.timeBounusValue = timeBonus
                        self.datactrl.saveGameData()
                    }
                    else
                    {
                        let alert = UIAlertView(title: "Too few hints", message: "Must have more than \(GlobalConstants.hintCostForTimeBonus) hints to expand time", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()

                    }
                    
            }))
            expandTimePrompt.addAction(UIAlertAction(title: "Cancel",
                style: .Default,
                handler: { (action) -> Void in
                    
            }))
            
            
            self.presentViewController(expandTimePrompt,
                animated: true,
                completion: nil)
        }
    }

    //MARK: Payment
    
    func requestProductData()
    {
        /*
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if adFree
        {
            return
        }
        */
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:  self.productIDs as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            
            
            product = products[0]
            
        } else {
            //productTitle.text = "Product not found"
        }
        
        for product in products
        {
            productList.append(product)
        }
        
        let invalidProducts = response.invalidProductIdentifiers
        
        for product in invalidProducts
        {
            print("Product not found: \(product)")
        }
    }
    
    
    
    func buyProductAction() {

        let payment = SKPayment(product: product!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                
                let prodID = product?.productIdentifier
                if prodID == productIdAdFree
                {
                    self.removeAds()
                }
                else if prodID == productIdAddHints
                {
                    self.addHints()
                }
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Restored:
                let prodID = product?.productIdentifier
                if prodID == productIdAdFree
                {
                    self.removeAds()
                }
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func removeAds() {
        
        removeAdsButton!.removeFromSuperview()
        datactrl.adFreeValue = 1
        datactrl.saveGameData()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "adFree")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.bannerView?.delegate = nil
        self.bannerView?.hidden = true
        bannerView?.frame.offsetInPlace(dx: 0, dy: bannerView!.frame.height)
    }
    
    func addHints()
    {
        var hints = NSUserDefaults.standardUserDefaults().integerForKey("hintsLeftOnAccount")
        hints = hints + GlobalConstants.numberOfHintsPrBuy
        statsView.hintsButton.sHints(hints)
        NSUserDefaults.standardUserDefaults().setInteger(hints, forKey: "hintsLeftOnAccount")
        NSUserDefaults.standardUserDefaults().synchronize()
        datactrl.hintsValue = hints
        datactrl.saveGameData()
    }

    var allowRotate = false
    override func shouldAutorotate() -> Bool {
        return allowRotate
    }
    
    func canRotate () -> Void{ }
    
    
    func recieveNumberOfResultsNotDownloaded()
    {
        
        let currentbadge = NSUserDefaults.standardUserDefaults().integerForKey("resultsBadge")
        if currentbadge == 0
        {
            if let token = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")
            {
                if token == ""
                {
                    return
                }
                let client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
                let jsonDictionaryHandle = ["token":token]
                client!.invokeAPI("idleresults", data: nil, HTTPMethod: "GET", parameters: jsonDictionaryHandle as [NSObject : AnyObject], headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
                    
                    
                    if error != nil
                    {
                        print("\(error)")
                        let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                        reportError?.reportError("\(error)")
                        /*
                        let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                        let alertController = reportError?.alertController("\(error)")
                        self.presentViewController(alertController!,
                            animated: true,
                            completion: nil)
                        */
                    }
                    if result != nil
                    {
                        var resultsBadge = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
                        resultsBadge = String(resultsBadge.characters.dropLast().dropFirst())
                        print(resultsBadge)
                        let resultsBadgeInt = Int(resultsBadge)
                        /*
                        var resultsBadgeInt: NSInteger = 0
                        result.getBytes(&resultsBadgeInt, length: sizeof(NSInteger))
                        NSUserDefaults.standardUserDefaults().setInteger(resultsBadgeInt, forKey: "resultsBadge")
                        */
                        dispatch_async(dispatch_get_main_queue()) {
                            self.resultsButton.setbadge(resultsBadgeInt!)
                        }

                    }
                    if response != nil
                    {
                        print("\(response)")
                    }

                    
                })
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue()) {
                self.resultsButton.setbadge(currentbadge)
            }
        }
        
    }
    
    func recieveNumberOfPendingChallenges()
    {
        
        let currentbadge = NSUserDefaults.standardUserDefaults().integerForKey("challengesBadge")
        if currentbadge == 0
        {
            if let token = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")
            {
                if token == ""
                {
                    return
                }
                
                let client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
                let jsonDictionaryHandle = ["token":token]
                client!.invokeAPI("pendingchallenges", data: nil, HTTPMethod: "GET", parameters: jsonDictionaryHandle as [NSObject : AnyObject], headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
                    
                    
                    if error != nil
                    {
                        print("\(error)")
                        
                        let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                        reportError?.reportError("\(error)")
                        /*
                        let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                        let alertController = reportError?.alertController("\(error)")
                        self.presentViewController(alertController!,
                            animated: true,
                            completion: nil)
                        */
                    }
                    if result != nil
                    {

                        /*
                        var resultsBadgeInt: NSInteger = 0
                        result.getBytes(&resultsBadgeInt, length: sizeof(NSInteger))
                        NSUserDefaults.standardUserDefaults().setInteger(resultsBadgeInt, forKey: "challengesBadge")
                        */
                        var resultsBadge = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
                        resultsBadge = String(resultsBadge.characters.dropLast().dropFirst())
                        
                        let resultsBadgeInt = Int(resultsBadge)
                        print(resultsBadgeInt)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.challengeUsersButton.setbadge(resultsBadgeInt!)
                            self.pendingChallengesButton.setbadge(resultsBadgeInt!)
                        }
                    }
                    if response != nil
                    {
                        print("\(response)")
                    }
                    
                    
                })
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue()) {
                self.challengeUsersButton.setbadge(currentbadge)
                self.pendingChallengesButton.setbadge(currentbadge)
            }
        }
        
    }

    
    func testAction()
    {
        //!!!! NOTE : devicetoken is clearly not in the right format for serverside. ???
        
        let handleToken = NSUserDefaults.standardUserDefaults().objectForKey("devicetoken") == nil ? "aaAAffFF" : NSUserDefaults.standardUserDefaults().objectForKey("devicetoken")!
        //register for notification
        let client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
        
        let jsonDictionaryHandle = ["handle":handleToken]
        client!.invokeAPI("registerfornotification", data: nil, HTTPMethod: "Post", parameters: jsonDictionaryHandle as [NSObject : AnyObject], headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
            
            if error != nil
            {
                print("\(error)")
            }
            if result != nil
            {
                print(result)
                ///backstabbing cock!!!.. is there really no way of escaping double quotes directly from json string...
                
                let temp = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
                
                let regId = String(temp.characters.dropLast().dropFirst())
                
                //_? self.testReg(regId,handleToken: handleToken)
                
                
            }
            if response != nil
            {
                print("\(response)")
            }
            
            
        })
    }
    
    
    
    
    func testReg(regid:String, handleToken:String)
    {
        var tags:[String] = []
        tags.append("knut")
        tags.append("dullum")
        let jsonDictionary = ["idreg":regid,"token":handleToken,"tag":"knut"]
        //var jsonDictionary = ["fbid":"10155943015600858","name":userName]
        let client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
        
        client!.invokeAPI("registerfornotification", data: nil, HTTPMethod: "PUT", parameters: jsonDictionary as [NSObject : AnyObject], headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
            if error != nil
            {
                print("\(error)")
            }
            if result != nil
            {
                
                do{
                    let jsonArray = try NSJSONSerialization.JSONObjectWithData(result, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                    
                    if let array = jsonArray
                    {
                        for item in array {
                            print("item : \(item)")
                        }
                        if jsonArray?.count == 0
                        {
                            print("hmm")
                        }
                        
                    }
                }
                catch
                {
                    print("\(error)")
                }
                
                
            }
            if response != nil
            {
                print("\(response)")
            }
            
        })
    }

}

