//
//  ResultsViewController.swift
//  PlaceInTime
//
//  Created by knut on 17/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import FBSDKLoginKit


class ResultsViewController: UIViewController, FBSDKLoginButtonDelegate {
    let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
    var client: MSClient?
    var activityLabel:UILabel!
    let backButton = UIButton()
    let filterButton = UIButton()
    var titleLabel:UILabel!
    var userId:String!
    var userName:String!
    
    var resultsScrollView:ResultsScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
        //FBSDKSettings.setAppID("154370428242475")
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            
            initUserData()
        }
        else
        {
            let loginButton: FBSDKLoginButton = FBSDKLoginButton()
            // Optional: Place the button in the center of your view.
            loginButton.center = self.view.center
            loginButton.delegate = self
            loginButton.readPermissions = ["public_profile", "user_friends"]
            self.view.addSubview(loginButton)
        }
        
        let backButtonMargin:CGFloat = 10
        backButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - GlobalConstants.smallButtonSide - backButtonMargin, backButtonMargin, GlobalConstants.smallButtonSide, GlobalConstants.smallButtonSide)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.borderColor = UIColor.blueColor().CGColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.setTitle("🔙", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backAction", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        

        /*
        filterButton.frame = CGRectMake(backButtonMargin, backButtonMargin, GlobalConstants.smallButtonSide, GlobalConstants.smallButtonSide)
        filterButton.backgroundColor = UIColor.whiteColor()
        filterButton.layer.borderColor = UIColor.grayColor().CGColor
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderWidth = 1
        filterButton.layer.cornerRadius = 5
        filterButton.setTitle("⚒", forState: UIControlState.Normal)
        filterButton.addTarget(self, action: "backAction", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(filterButton)
*/
    }
    
    func initUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : String = result.valueForKey("name") as! String
                print("User Name is: \(userName)")
                self.userName = userName
                let userId2 = result.valueForKey("id") as! String
                print("UserId2 is: \(userId2)")
                self.userId = userId2
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).backgroundThread(background: {
                    self.updateUser({() -> Void in
                    })
                    
                })
                
                self.initAndCollect()
                
                result
            }
        })
    }
    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            print("Error: \(error)")
            // Process error
            let alert = UIAlertView(title: "Facebook login error", message: "Something went wrong at login. Try again later", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            logOut()
        }
        else if result.isCancelled {
            print("FB login cancelled")
            // Handle cancellations
            logOut()
        }
        else {
            
            initUserData()
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("user_friends")
            {
                
            }
            else
            {
                //TODO show logout button and message telling that friends list must be premitted to continue
                let alert = UIAlertView(title: "Friendslist", message: "Friendslist must be premitted to play against friends", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                logOut()
            }
            
            
        }
    }
    
    func initAndCollect()
    {
        initElements()
        collectNewResults()
    }
    
    func logOut()
    {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        self.performSegueWithIdentifier("segueFromResultsToMainMenu", sender: nil)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.logOut()
    }
    
    func initElements()
    {
        let margin:CGFloat = 10
        let elementWidth:CGFloat = 200
        let elementHeight:CGFloat = 40
        titleLabel = UILabel(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - (elementWidth / 2), margin, elementWidth, elementHeight))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.boldSystemFontOfSize(24)
        titleLabel.text = "Results"
        view.addSubview(titleLabel)
        
        
        let scrollViewHeight =  UIScreen.mainScreen().bounds.size.height - titleLabel.frame.maxY - ( margin * 2 )
        let scrollViewWidth = UIScreen.mainScreen().bounds.size.width - (margin * 2)
        self.resultsScrollView = ResultsScrollView(frame: CGRectMake(margin , titleLabel.frame.maxY + margin, scrollViewWidth, scrollViewHeight))
        self.resultsScrollView.alpha = 1
        self.view.addSubview(self.resultsScrollView)
        
        
        activityLabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width * 0.1, 0, UIScreen.mainScreen().bounds.size.width * 0.8, 50))
        activityLabel.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        activityLabel.adjustsFontSizeToFitWidth = true
        activityLabel.textAlignment = NSTextAlignment.Center
        activityLabel.text = ""
        self.view.addSubview(activityLabel)


    }
    

    func collectNewResults()
    {
        let oldNumerbOfRecords = datactrl.gameResultsValues.count
        activityLabel.text = "Collecting new results..."
        //FB LOGIN
        let jsonDictionary = ["fbid":self.userId]
        
        self.client!.invokeAPI("collectchallengesV2", data: nil, HTTPMethod: "GET", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
            if error != nil
            {
                print("\(error)")
                self.activityLabel.text = "Server error"
                let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                let alertController = reportError?.alertController("\(error)")
                self.presentViewController(alertController!,
                    animated: true,
                    completion: nil)
            }
            if result != nil
            {

                do{
                    let jsonArray = try NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                    
                    if jsonArray?.count > 0
                    {
                        self.saveChallengeToPlist(jsonArray as! [NSDictionary])
                    }
                } catch {
                    print(error)
                }
                self.activityLabel.alpha = 0
                self.collectStoredResults(oldNumerbOfRecords)
                
            }
            if response != nil
            {
                print("\(response)")
            }
        })
    }
    
    func updateUser(completionClosure: (() -> Void) )
    {
        
        let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")
        let jsonDictionary = ["fbid":userId,"name":userName,"token":deviceToken == nil ? "" : deviceToken]
        
        self.client!.invokeAPI("updateuser", data: nil, HTTPMethod: "POST", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
            if error != nil
            {
                print("\(error)")
                
                let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                let alertController = reportError?.alertController("\(error)")
                self.presentViewController(alertController!,
                    animated: true,
                    completion: nil)
            }
            /*
            //NO result
            */
            if response != nil
            {
                print("\(response)")
            }
            
            completionClosure()
        })
    }
    
    func collectStoredResults(oldNumerbOfRecords:Int)
    {
        var distinctUsers:[String] = []
        let minNumberOfItemsOnGamerecordRow = 5
        var noValues = true
        datactrl.loadGameData()
        let usingKm = NSUserDefaults.standardUserDefaults().boolForKey("useKm")
        var index = 0
        for record in datactrl.gameResultsValues
        {
            let arrayOfValues = record.componentsSeparatedByString(",")
            if arrayOfValues.count >= minNumberOfItemsOnGamerecordRow
            {
                let newRecord = oldNumerbOfRecords <= index
                index++
                
                let myDistance = NSNumberFormatter().numberFromString(arrayOfValues[0] )
                var myDistanceRightMeasure =  usingKm ? myDistance!.integerValue : Int(CGFloat(myDistance!.integerValue) * 0.621371)
                if myDistance!.integerValue == GlobalConstants.bailedValue
                {
                    myDistanceRightMeasure = GlobalConstants.bailedValue
                }
                let name = arrayOfValues[1]
                if !distinctUsers.contains(name)
                {
                    distinctUsers.append(name)
                }
                let opponentDistance = NSNumberFormatter().numberFromString(arrayOfValues[2] )
                var opponentDistanceRightMeasure =  usingKm ? opponentDistance!.integerValue : Int(CGFloat(opponentDistance!.integerValue) * 0.62137)
                if opponentDistance!.integerValue == GlobalConstants.bailedValue
                {
                    opponentDistanceRightMeasure = GlobalConstants.bailedValue
                }
                let title = arrayOfValues.count > 3 ? arrayOfValues[3] : "-"
                let date = arrayOfValues.count > 4 ? arrayOfValues[4] : "-"
                let opponentId = arrayOfValues.count > 5 ? arrayOfValues[5] : ""
                resultsScrollView.addItem( myDistanceRightMeasure, opponentName: name, opponentId: opponentId, opponentDistance: opponentDistanceRightMeasure, title:title, date:date, newRecord: newRecord)
                
                noValues = false
            }
        }
        
        resultsScrollView.setFilter(distinctUsers)
        if noValues
        {
            self.activityLabel.alpha = 1
            self.activityLabel.text = "No results😑 Challenge other players😊"
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.resultsScrollView.layoutResult(0)
                })
        }
        resultsScrollView.setResultText()

    }

    
    func saveChallengeToPlist(values:[NSDictionary])
    {
        for item in values
        {
            let myDistance = item["mydistance"] as! Int
            let name = item["opponentname"] as! String
            let opponentDistance = item["opponentdistance"] as! Int
            let title = item["title"] as! String
            let date = item["date"] as! String
            let opponentId = item["opponentid"] as! String
            let valuesStringFormat:String = "\(myDistance),\(name),\(opponentDistance),\(title),\(date),\(opponentId)"
            
            datactrl.addRecordToGameResults(valuesStringFormat)
        }
        datactrl.saveGameData()
    }
    
    func backAction()
    {
        self.performSegueWithIdentifier("segueFromResultsToMainMenu", sender: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
