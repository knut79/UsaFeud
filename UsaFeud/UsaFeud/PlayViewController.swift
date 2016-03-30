
//
//  ViewController.swift
//  MapFeud
//
//  Created by knut on 05/10/15.
//  Copyright © 2015 knut. All rights reserved.
//

import UIKit
import iAd

class PlayViewController: UIViewController , MapDelegate,ADBannerViewDelegate, ClockProtocol {

    var datactrl:DataHandler!
    var map:MapScrollView!
    var playerIcon:PlayerIconView!
    var magnifyingGlass: MagnifyingGlassView!
    var magnifyingGlassLeftPos:CGPoint!
    var magnifyingGlassRightPos:CGPoint!
    var questionView:QuestionView!
    var answerView:AnswerView!
    var currentQuestion:Question!
    var distanceView:DistanceView!
    
    /*
    var levelHigh:Int = 1
    var levelLow:Int = 1
    var tags:[String] = []
    */
    var gametype:GameType!
    var usersIdsToChallenge:[String] = []
    var completedQuestionsIds:[String] = []
    var numOfQuestionsForRound:Int!
    var myIdAndName:(String,String)!
    
    var challenge:Challenge!
    
    var hintButton:HintButton!
    var okButton:OkButton!
    var nextButton:UIButton!
    var nextButtonVisibleOrigin:CGPoint!
    var nextButtonHiddenOrigin:CGPoint!
    
    var backButton:UIButton?
    var backButtonOrgFrame:CGRect?
    var backButtonVisibleOrigin:CGPoint!
    var backButtonHiddenOrigin:CGPoint!
    
    var drawBorders:Bool = false
    
    var clock:ClockView?
    var orgClockCenter:CGPoint!
    
    var bannerView:ADBannerView?
    
    var usingKm:Bool = true
    //var questonsLeft:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        

        usingKm = NSUserDefaults.standardUserDefaults().boolForKey("useKm")
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        if !adFree
        {
            self.canDisplayBannerAds = true
            bannerView = ADBannerView(frame: CGRectZero)
            bannerView!.center = CGPoint(x: bannerView!.center.x, y: self.view.bounds.size.height - bannerView!.frame.size.height / 2)
            self.view.addSubview(bannerView!)
            self.bannerView?.delegate = self
            self.bannerView?.hidden = false
        }
        let mapHeight = adFree ? UIScreen.mainScreen().bounds.height : UIScreen.mainScreen().bounds.height - bannerView!.frame.height
        
        if gametype == GameType.takingChallenge
        {
            drawBorders = (challenge as! TakingChallenge).usingBorders == 1 ? true : false
        }
        else if gametype == GameType.badgeChallenge
        {
            drawBorders = (challenge as! BadgeChallenge).usingBorders == 1 ? true : false
        }
        
        map = MapScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, mapHeight), drawBorders: drawBorders)
        map.delegate = self
        
        playerIcon = PlayerIconView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 0.12, UIScreen.mainScreen().bounds.width * 0.12))
        playerIcon.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        playerIcon.userInteractionEnabled = true
        map.addSubview(playerIcon)
        
        datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayViewController.tapMap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        map.addGestureRecognizer(singleTapGestureRecognizer)
        
        self.view.addSubview(map)
        
        let questonViewHeight = UIScreen.mainScreen().bounds.height * 0.1
        
        let magnifyingSide = UIScreen.mainScreen().bounds.width * 0.22
        magnifyingGlass = MagnifyingGlassView(frame: CGRectMake( 0 , 0 ,magnifyingSide , magnifyingSide))
        magnifyingGlassLeftPos = CGPointMake((magnifyingSide / 2) ,questonViewHeight + (magnifyingSide / 2))
        magnifyingGlassRightPos = CGPointMake(UIScreen.mainScreen().bounds.width - (magnifyingSide / 2) , questonViewHeight + (magnifyingSide / 2))
        magnifyingGlass.center = magnifyingGlassLeftPos
        magnifyingGlass.mapToMagnify = map
        magnifyingGlass.alpha = 0
        self.view.addSubview(magnifyingGlass)
        
        distanceView = DistanceView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 0.66, questonViewHeight),usingKm:self.usingKm)
        distanceView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, map.bounds.maxY - (questonViewHeight / 2))
        distanceView.alpha = 1
        distanceView.userInteractionEnabled = false
        self.view.addSubview(distanceView)
        distanceView.orgFrame = distanceView.frame
        if gametype == GameType.badgeChallenge
        {
            distanceView.forceHide()
        }
        
        setupButtons()
        
        questionView = QuestionView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, questonViewHeight))
        questionView.alpha = 0
        self.view.addSubview(questionView)
        questionView.orgFrame = questionView.frame
        
        answerView = AnswerView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, questonViewHeight))
        answerView.alpha = 0
        self.view.addSubview(answerView)
        
        
        if gametype != GameType.training
        {
            clock = ClockView(frame: CGRectMake(0, 0, magnifyingSide, magnifyingSide))
            orgClockCenter = magnifyingGlassRightPos
            clock?.center = orgClockCenter
            clock?.delegate = self
            view.addSubview(clock!)
        }
        
        startGame()
    }
    
    func setupButtons()
    {
        let margin = UIScreen.mainScreen().bounds.width * 0.025
        
        let buttonSide = UIScreen.mainScreen().bounds.width * 0.15
        
        hintButton = HintButton(frame: CGRectMake(0, 0, buttonSide, buttonSide))
        hintButton.center = CGPointMake(margin + (hintButton.frame.width / 2) , UIScreen.mainScreen().bounds.height * 0.33)
        hintButton.addTarget(self, action: #selector(PlayViewController.useHintAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(hintButton)
        hintButton.orgFrame = hintButton.frame

        let okButtonSide = buttonSide + margin
        okButton = OkButton(frame: CGRectMake(map.bounds.width - okButtonSide , map.bounds.height - okButtonSide , okButtonSide, okButtonSide),rightMargin: margin,bottomMargin: margin)
       // okButton.center = CGPointMake(map.bounds.width - (okButton.frame.width / 2) - margin , map.bounds.height - (okButton.frame.height / 2) - margin)
        okButton.addTarget(self, action: #selector(PlayViewController.okAction), forControlEvents: UIControlEvents.TouchUpInside)
                self.view.addSubview(okButton)
        okButton.orgFrame = okButton.frame
            
        nextButton = UIButton(frame: CGRectMake(0, 0, buttonSide, buttonSide))
        nextButton.center = CGPointMake(map.bounds.width - (nextButton.frame.width / 2) - margin , map.bounds.height - (nextButton.frame.height / 2) - margin)
        nextButton.addTarget(self, action: #selector(PlayViewController.nextAction), forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.setTitle("⏩", forState: UIControlState.Normal)
        nextButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        nextButton.layer.borderWidth = 2
        nextButton.layer.cornerRadius = nextButton.bounds.size.width / 2
        nextButton.layer.masksToBounds = true
        self.view.addSubview(nextButton)
        nextButtonVisibleOrigin = nextButton.center
        //initially hide next button
        nextButtonHiddenOrigin = CGPointMake(UIScreen.mainScreen().bounds.maxX + nextButton.frame.width, nextButton.center.y)
        nextButton.center = nextButtonHiddenOrigin
        
        if gametype == GameType.training
        {
            backButton = UIButton(frame: CGRectMake(margin, map.bounds.maxY - buttonSide - margin, buttonSide, buttonSide))
            backButton!.addTarget(self, action: #selector(PlayViewController.backAction), forControlEvents: UIControlEvents.TouchUpInside)
            backButton!.setTitle("⏪", forState: UIControlState.Normal)
            backButton!.layer.borderColor = UIColor.lightGrayColor().CGColor
            backButton!.layer.borderWidth = 2
            backButton!.layer.cornerRadius = backButton!.bounds.size.width / 2
            backButton!.layer.masksToBounds = true
            self.view.addSubview(backButton!)
            backButtonVisibleOrigin = backButton!.center
            //initially hide next button
            backButtonHiddenOrigin = CGPointMake(backButton!.frame.width * -1 , backButton!.center.y)
            //backButton!.center = backButtonHiddenOrigin
            backButtonOrgFrame = backButton!.frame
        }

    }

    func useHintAction()
    {
        var hintText:String?
        if self.hintButton.hintsLeftOnAccount == 0
        {
            hintText = "Add more hints from main menu"
        }
        else if self.hintButton.hintsLeftOnQuestion >= 2
        {
            hintText = currentQuestion.place.hint1
            self.hintButton.deductHints()
        }
        else if self.hintButton.hintsLeftOnQuestion >= 1
        {
            hintText = currentQuestion.place.hint2
            self.hintButton.deductHints()
        }
        

        if let text = hintText
        {
            let alert = UIAlertView(title: "Hint", message: text, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
 
        }
    }
    
    func backAction()
    {
        self.performSegueWithIdentifier("segueFromPlayToMainMenu", sender: nil)
    }
    
    func okAction()
    {
        okButton.userInteractionEnabled = false
        nextButton.userInteractionEnabled = true
        clock?.stop()
        clock?.alpha = 0
        
        self.playerIcon.alpha = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.hintButton.hide()
            self.okButton.hide()
            }, completion: { (value: Bool) in
                self.setPoint()
                
        })
        
    }
    
    func setPoint()
    {
        playerIcon.alpha = 0
        map.setPoint(playerIcon.center)
        let questionPlace = currentQuestion.place

        map.animateAnswer(questionPlace)
    }
    
    func finishedAnimatingAnswer(distance:Int,insidePerfectWindow:Bool,insideOkWindow:Bool)
    {
        if let qv = answerView
        {
            qv.setAnswer(currentQuestion, distance: distance)
        }
        
        if gametype != GameType.training
        {
            if distance <= 0
            {
                currentQuestion.rightAnsw += 1
                datactrl.save()
            }
        }
        
        if gametype == GameType.badgeChallenge
        {
            if let badgeChallenge = (challenge as? BadgeChallenge)
            {

                if distance > 0 && !insideOkWindow
                {
                    //challenge is lost
                    challenge.questionIds.removeAll()
                    badgeChallenge.won = false
                    
                }
                
                showAnswer({() -> Void in
                    
                    self.animateRightOrWrong(distance,insidePerfectWindow: insidePerfectWindow, insideOkWindow: insideOkWindow,completion: {() -> Void in
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.hideNextButton(false)
                            self.hintButton.hide()
                            
                        })
                        
                        
                    })
                })
                
            }
        }
        else
        {
        
            showAnswer({() -> Void in

                self.animateDistanceToAdd(distance,completion: {() -> Void in
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.hideNextButton(false)
                        self.hintButton.hide()

                        })
                })
            })
        }

    }
    
    func animateRightOrWrong(distance:Int, insidePerfectWindow:Bool, insideOkWindow:Bool,completion: (() -> (Void)))
    {
        let tempIconAnimateLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width / 2, 50))
        tempIconAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempIconAnimateLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(tempIconAnimateLabel)
        
        let tempDisctanceAnimateLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width / 2, 50))
        tempDisctanceAnimateLabel.textColor = UIColor.whiteColor()
        tempDisctanceAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempDisctanceAnimateLabel.textAlignment = NSTextAlignment.Center
        tempDisctanceAnimateLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(tempDisctanceAnimateLabel)
        
        tempDisctanceAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempDisctanceAnimateLabel.alpha = 0
        let distanceText = usingKm ? "\(distance) km" : "\(Int(CGFloat(distance) * 0.621371)) miles"
        

        if insidePerfectWindow
        {
            tempDisctanceAnimateLabel.text = "Correct location"
        }
        else if insideOkWindow
        {
            tempDisctanceAnimateLabel.text = "Close enough"
        }
        else
        {
            tempDisctanceAnimateLabel.text = "Wrong by \(distanceText)"
        }
        
        
        tempIconAnimateLabel.text = getEmojiOnWindow(insidePerfectWindow,windowOk: insideOkWindow)
        tempIconAnimateLabel.alpha = 0
        tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 0.1, 0.1)
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            tempIconAnimateLabel.alpha = 1
            tempIconAnimateLabel.transform = CGAffineTransformIdentity
            tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 3, 3)
            tempIconAnimateLabel.frame.offsetInPlace(dx: 0, dy: UIScreen.mainScreen().bounds.height * 0.1)
            tempDisctanceAnimateLabel.transform = CGAffineTransformScale(tempDisctanceAnimateLabel.transform, 2, 2)
            tempDisctanceAnimateLabel.frame.offsetInPlace(dx: 0, dy: UIScreen.mainScreen().bounds.height * 0.25)
            tempDisctanceAnimateLabel.alpha = 1
            }, completion: { (value: Bool) in
                
                UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    //tempIconAnimateLabel.transform = CGAffineTransformIdentity
                    tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 6, 6)
                    tempIconAnimateLabel.alpha = 0
                    
                    tempDisctanceAnimateLabel.center = self.view.center
                    tempDisctanceAnimateLabel.transform = CGAffineTransformScale(tempDisctanceAnimateLabel.transform, 2, 2)
                    tempDisctanceAnimateLabel.alpha = 0
                    
                    /*
                    if distance > 0
                    {
                        tempDisctanceAnimateLabel.center = self.distanceView.center
                        tempDisctanceAnimateLabel.transform = CGAffineTransformIdentity
                    }
                    else
                    {
                        tempDisctanceAnimateLabel.center = self.view.center
                        tempDisctanceAnimateLabel.transform = CGAffineTransformScale(tempDisctanceAnimateLabel.transform, 2, 2)
                        tempDisctanceAnimateLabel.alpha = 0
                    }
                    */
                    }, completion: { (value: Bool) in
                        tempDisctanceAnimateLabel.removeFromSuperview()
                        tempIconAnimateLabel.removeFromSuperview()
                        
                        /*
                        if distance > 0
                        {
                            self.distanceView.addDistance(distance)
                        }
                        */
                        
                        completion()
                        
                })
                
        })
    }
    
    func animateDistanceToAdd(distance:Int,completion: (() -> (Void)))
    {
        let tempIconAnimateLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width / 2, 50))
        tempIconAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempIconAnimateLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(tempIconAnimateLabel)
        
        let tempDisctanceAnimateLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width / 2, 50))
        tempDisctanceAnimateLabel.textColor = UIColor.whiteColor()
        tempDisctanceAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempDisctanceAnimateLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(tempDisctanceAnimateLabel)

        tempDisctanceAnimateLabel.center = CGPointMake( UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        tempDisctanceAnimateLabel.alpha = 0
        let distanceText = usingKm ? "\(distance) km" : "\(Int(CGFloat(distance) * 0.621371)) miles"
        tempDisctanceAnimateLabel.text = distance > 0 ? distanceText : "Correct location"
        
        tempIconAnimateLabel.text = getEmojiOnMissedDistance(distance)
        tempIconAnimateLabel.alpha = 0
        tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 0.1, 0.1)
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            tempIconAnimateLabel.alpha = 1
            tempIconAnimateLabel.transform = CGAffineTransformIdentity
            tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 3, 3)
            tempIconAnimateLabel.frame.offsetInPlace(dx: 0, dy: UIScreen.mainScreen().bounds.height * 0.1)
            tempDisctanceAnimateLabel.transform = CGAffineTransformScale(tempDisctanceAnimateLabel.transform, 2, 2)
            tempDisctanceAnimateLabel.frame.offsetInPlace(dx: 0, dy: UIScreen.mainScreen().bounds.height * 0.25)
            tempDisctanceAnimateLabel.alpha = 1
            }, completion: { (value: Bool) in
                
                UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    //tempIconAnimateLabel.transform = CGAffineTransformIdentity
                    tempIconAnimateLabel.transform = CGAffineTransformScale(tempIconAnimateLabel.transform, 6, 6)
                    tempIconAnimateLabel.alpha = 0

                    if distance > 0
                    {
                        tempDisctanceAnimateLabel.center = self.distanceView.center
                        tempDisctanceAnimateLabel.transform = CGAffineTransformIdentity
                    }
                    else
                    {
                        tempDisctanceAnimateLabel.center = self.view.center
                        tempDisctanceAnimateLabel.transform = CGAffineTransformScale(tempDisctanceAnimateLabel.transform, 2, 2)
                        tempDisctanceAnimateLabel.alpha = 0
                    }
                    
                    }, completion: { (value: Bool) in
                        tempDisctanceAnimateLabel.removeFromSuperview()
                        tempIconAnimateLabel.removeFromSuperview()
                        if distance > 0
                        {
                            self.distanceView.addDistance(distance)
                        }
                        
                        completion()
                        
                })

        })
    }
    
    func getEmojiOnWindow(windowPerfect:Bool,windowOk:Bool) -> String
    {
        var emoji = "😫"
        
        if gametype == GameType.badgeChallenge
        {
            if windowPerfect{
                emoji = "😀"
            }
            else if windowOk {
                emoji = "😌"
            }
        }
        return emoji
    }
    
    func getEmojiOnMissedDistance(missedDistance:Int) -> String
    {
        var emoji = "😀"

        if(missedDistance > 2000){
            emoji = "😭"
        }
        else if(missedDistance > 1200){
            emoji = "😫"
        }
        else if(missedDistance > 600){
            emoji = "😬"
        }
        else if(missedDistance > 250){
            emoji = "😐"
        }
        else if(missedDistance > 0){
            emoji = "😌"
        }
    
        return emoji
    }
    
    
    
    func showAnswer(completion: (() -> (Void)))
    {
        
        answerView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        self.answerView.answerText.textColor = UIColor.whiteColor()
        self.answerView.userInteractionEnabled = true
        
        self.answerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        self.answerView.transform = CGAffineTransformScale(self.answerView.transform, 0.1, 0.1)
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            self.questionView.alpha = 0
            self.answerView.alpha = 1
            self.answerView.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                
                UIView.animateWithDuration(1, animations: { () -> Void in
                    
                    self.answerView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, self.questionView.frame.height / 2)
                    self.answerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
                    
                    
                    }, completion: { (value: Bool) in
                        
                        self.answerView.finishedAnimating()
                        completion()

                        
                })
            })
    }
    
    func nextAction()
    {
        okButton.userInteractionEnabled = true
        nextButton.userInteractionEnabled = false
        
        map.clearDrawing()
        self.answerView.userInteractionEnabled = false
        self.hintButton.restoreHints()
        self.clock?.transform = CGAffineTransformIdentity
        self.clock?.center = orgClockCenter
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            //self.hideHintButton(false)
            self.hintButton.hide(false)
            self.okButton.hide(false)
            
            self.hideNextButton()
            }, completion: { (value: Bool) in
                self.setNextQuestion()
                self.playerIcon.alpha = 1
        })

        
    }
    
    var questionindex = 0
    func startGame()
    {
        //questonsLeft = //GlobalConstants.numberOfQuestionsForChallenge
        setNextQuestion()
    }
    
    func setNextQuestion()
    {
        if self.gametype == GameType.training
        {
            currentQuestion = datactrl.questionItems[questionindex % datactrl.questionItems.count]
            questionindex += 1
        }
        else
        {
            
            if challenge.questionIds.count > 0
            {
                let questionID = challenge.questionIds.removeLast()
                print("questionID to fetch \(questionID)")
                currentQuestion = datactrl.fetchQuestion(questionID)
            }
            else
            {
                currentQuestion = nil
            }
        }
        //currentQuestion = datactrl.fetchPlace("Japan")!.questions.allObjects[0] as! Question
        
        
        if let q = currentQuestion
        {
            if let qv = questionView
            {
                qv.setQuestion(q)
            }
            showQuestion()
        }
        else
        {
            //end game 
            self.performSegueWithIdentifier("segueFromPlayToFinished", sender: nil)
            
        }
        
    }
    
    func showQuestion()
    {
        questionView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        self.questionView.questionText.textColor = UIColor.whiteColor()
        
        let timeBonus = NSUserDefaults.standardUserDefaults().integerForKey("timeBonus")
        var time:Double = GlobalConstants.timeStart
        for _ in 1 ... timeBonus
        {
            time = time * GlobalConstants.timeBonusMultiplier
        }
        self.clock?.start(time)
        
        self.questionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        self.questionView.transform = CGAffineTransformScale(self.questionView.transform, 0.1, 0.1)
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            self.answerView.alpha = 0
            self.questionView.alpha = 1
            self.questionView.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                
                UIView.animateWithDuration(1, animations: { () -> Void in
                    
                    self.questionView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, self.questionView.frame.height / 2)
                    self.questionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
                    self.clock?.alpha = 1
                    
                    }, completion: { (value: Bool) in
                        
                        self.questionView.questionText.textColor = UIColor.blackColor()
                        /*
                        let timeBonus = NSUserDefaults.standardUserDefaults().integerForKey("timeBonus")
                        var time:Double = GlobalConstants.timeStart
                        for var i = 1 ; i <= timeBonus; i++
                        {
                           time = time * GlobalConstants.timeBonusMultiplier
                        }
                        self.clock?.start(time)
                        */
                        self.showQuestionsLeft()
                        
                })
                
        })
    }
    
    func showQuestionsLeft()
    {
        if gametype != GameType.training
        {
            let questionsLeftOfChallenge = challenge.questionIds.count + 1
            let questionsLeft = UILabel(frame: CGRectMake(clock!.frame.minX, clock!.frame.minY, clock!.frame.width, clock!.frame.height * 0.66))
            questionsLeft.text = questionsLeftOfChallenge <= 1 ? "Last" : "\(questionsLeftOfChallenge)"
            questionsLeft.font = UIFont.boldSystemFontOfSize(50)
            questionsLeft.textAlignment = NSTextAlignment.Center
            questionsLeft.adjustsFontSizeToFitWidth = true
            questionsLeft.textColor = UIColor.whiteColor()
            self.view.addSubview(questionsLeft)
            
            let textLeft = UILabel(frame: CGRectMake(questionsLeft.frame.minX, questionsLeft.frame.maxY, questionsLeft.frame.width, clock!.frame.height * 0.33))
            textLeft.text = questionsLeftOfChallenge <= 1 ? "question" : "questions\nleft"
            textLeft.font = UIFont.boldSystemFontOfSize(20)
            textLeft.textAlignment = NSTextAlignment.Center
            textLeft.numberOfLines = 2
            textLeft.adjustsFontSizeToFitWidth = true
            textLeft.textColor = UIColor.whiteColor()
            self.view.addSubview(textLeft)
            
            UIView.animateWithDuration(4, animations: { () -> Void in
                
                questionsLeft.alpha = 0
                textLeft.alpha = 0
                }, completion: { (value: Bool) in
                    questionsLeft.removeFromSuperview()
                    textLeft.removeFromSuperview()
                    //self.questonsLeft!--
            })
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInView(self.view)
        
        let isInnView = CGRectContainsPoint(playerIcon!.frame,touchLocation)
        if(isInnView)
        {
            magnifyingGlass.center = touchLocation
            playerIcon.center = touchLocation
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.magnifyingGlass.alpha = 1
                    self.magnifyingGlass.center = self.magnifyingGlassRightPos
                    self.magnifyingGlass.transform = CGAffineTransformIdentity
                    self.playerIcon.transform = CGAffineTransformScale(self.playerIcon.transform, 1.3, 1.3)
                }, completion: { (value: Bool) in
            })
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first //touches.anyObject()
        let touchLocation = touch!.locationInView(self.view)
        let isInnView = CGRectContainsPoint(playerIcon.frame,touchLocation)

        if(isInnView)
        {
            let isInnHintButtonView = CGRectContainsPoint(hintButton.orgFrame, touchLocation)
            let isInnOkButtonView = CGRectContainsPoint(okButton.orgFrame, touchLocation)
            let isInnMagnifyingView = CGRectContainsPoint(magnifyingGlass.frame,touchLocation)
            let isInnQuestionView = CGRectContainsPoint(questionView.orgFrame,touchLocation)
            let isInnDistanceView = CGRectContainsPoint(distanceView.orgFrame, touchLocation)
            let isInnBackButtonView = backButton != nil ? CGRectContainsPoint(self.backButtonOrgFrame!, touchLocation) : false
            if(isInnMagnifyingView)
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    if self.magnifyingGlass.center == self.magnifyingGlassLeftPos
                    {
                        self.magnifyingGlass.center = self.magnifyingGlassRightPos
                        self.clock?.center = self.magnifyingGlassRightPos
                    }
                    else
                    {
                        self.magnifyingGlass.center = self.magnifyingGlassLeftPos
                        self.clock?.center = self.magnifyingGlassLeftPos
                    }
                })
            }
            else if isInnHintButtonView || isInnQuestionView || isInnOkButtonView || isInnDistanceView || isInnBackButtonView
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    /*
                    if self.hintButton.frame == self.hintButtonOrgFrame && isInnHintButtonView
                    {
                        self.hideHintButton()
                    }
                    */
                    if self.hintButton.isVisible() && isInnHintButtonView
                    {
                        self.hintButton.hide()
                    }
                    if self.questionView.isVisible() && isInnQuestionView
                    {
                        self.questionView.hide()
                    }
                    if self.okButton.isVisible() && isInnOkButtonView
                    {
                        self.okButton.hide()
                    }
                    if let button = self.backButton
                    {
                        if isInnBackButtonView && button.frame == self.backButtonOrgFrame
                        {
                            self.hideBackButton()
                        }
                    }
                    if self.distanceView.isVisible() && isInnDistanceView
                    {
                        self.distanceView.hide()
                    }

                })
            }
            else
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in

                    if !self.hintButton.isVisible()
                    {
                        self.hintButton.hide(false)
                    }
                    if !self.questionView.isVisible()
                    {
                        self.questionView.hide(false)
                    }
                    if !self.okButton.isVisible()
                    {
                        self.okButton.hide(false)
                    }
                    if let button = self.backButton
                    {
                        if button.frame != self.backButtonOrgFrame
                        {
                            self.hideBackButton(false)
                        }
                    }
                    if !self.distanceView.isVisible()
                    {
                        self.distanceView.hide(false)
                    }
                })
            }
            
            playerIcon.alpha = 0
            magnifyingGlass.setTouchPoint(touchLocation)
            magnifyingGlass.setNeedsDisplay()
            
            let point = touches.first!.locationInView(self.view) //touches.anyObject()!.locationInView(self.view)
            //playerIcon.center = CGPointMake(point.x - xOffset, point.y - yOffset)
            playerIcon.center = CGPointMake(point.x , point.y)
        }
        else
        {
            let isInnAnswerView = CGRectContainsPoint(self.answerView.frame,touchLocation)
            if(!isInnAnswerView)
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.playerIcon.alpha = 1
                    self.magnifyingGlass.alpha = 0
                    self.magnifyingGlass.center = touchLocation
                    self.magnifyingGlass.transform = CGAffineTransformScale(self.magnifyingGlass.transform, 0.1, 0.1)
                    self.playerIcon.transform = CGAffineTransformIdentity
                    }, completion: { (value: Bool) in

                })
            }

        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInView(self.view)
        let isInnView = CGRectContainsPoint(self.playerIcon!.frame,touchLocation)
        if(isInnView)
        {
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.playerIcon.alpha = 1
                self.okButton.hide(false)
                self.hintButton.hide(false)
                self.questionView.hide(false)
                self.distanceView.hide(false)
                
                self.magnifyingGlass.alpha = 0
                self.magnifyingGlass.center = touchLocation
                self.magnifyingGlass.transform = CGAffineTransformScale(self.magnifyingGlass.transform, 0.1, 0.1)
                self.playerIcon.transform = CGAffineTransformIdentity
                }, completion: { (value: Bool) in
                    
            })
        }
        else if magnifyingGlass.alpha == 1
        {
            self.playerIcon.alpha = 1
            self.okButton.hide(false)
            self.hintButton.hide(false)
            self.questionView.hide(false)
            self.distanceView.hide(false)
            self.magnifyingGlass.alpha = 0
            self.magnifyingGlass.transform = CGAffineTransformScale(self.magnifyingGlass.transform, 0.1, 0.1)
            self.playerIcon.transform = CGAffineTransformIdentity
        }
    }

    func hideNextButton(hide:Bool = true)
    {
        if hide
        {
            self.nextButton.center = nextButtonHiddenOrigin
        }
        else
        {
            self.nextButton.center = nextButtonVisibleOrigin
        }
    }
    
    func hideBackButton(hide:Bool = true)
    {
        if hide
        {
            self.backButton?.center = self.backButtonHiddenOrigin
        }
        else
        {
            self.backButton?.center = self.backButtonVisibleOrigin
        }
    }
    
    
    
    func tapMap(gesture:UITapGestureRecognizer)
    {
        let touchLocation = gesture.locationInView(self.map)
        playerIcon.center = touchLocation
        
        self.playerIcon.transform = CGAffineTransformScale(self.playerIcon.transform, 1.3, 1.3)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.playerIcon.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
        })
    }
    
    func timeup()
    {
        okButton.userInteractionEnabled = false
        nextButton.userInteractionEnabled = true
        print("timeup")
        animateTimeup({() -> Void in

            self.setPoint()
        })
    }
    
    func animateTimeup(completion: (() -> (Void)))
    {
        let midscreen = CGPointMake(UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY)
        let label = UILabel(frame: CGRectMake(0, 0, 100, 40))
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(20)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.text = "Time is up"
        label.alpha = 0
        label.center = midscreen
        label.transform = CGAffineTransformScale(label.transform, 0.1, 0.1)
        self.view.addSubview(label)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.clock?.center = midscreen
                self.hintButton.hide()
                self.okButton.hide()
            }, completion: { (value: Bool) in
                
            UIView.animateWithDuration(0.5, animations: { () -> Void in

                
                label.alpha = 1
                label.transform = CGAffineTransformIdentity
                
                self.clock?.transform = CGAffineTransformScale(self.clock!.transform, 3, 3)
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.clock?.alpha = 0
                        label.alpha = 0
                        }, completion: { (value: Bool) in
                            label.removeFromSuperview()
                            completion()
                    })
            })
        })
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {

        self.clock?.stop()
        self.clock = nil
        if (segue.identifier == "segueFromPlayToFinished") {
            let svc = segue!.destinationViewController as! FinishedViewController

            if gametype == GameType.makingChallenge || gametype == GameType.takingChallenge
            {
                svc.userFbId = myIdAndName.0
            }

            svc.distance = self.distanceView.distance
            svc.gametype = gametype
            svc.challenge = challenge

        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


}

