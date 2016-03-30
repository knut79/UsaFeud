//
//  LoginViewController.swift
//  PlaceInTime
//
//  Created by knut on 06/09/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKShareKit


class ChallengeViewController:UIViewController,FBSDKLoginButtonDelegate, UserViewProtocol,FBSDKAppInviteDialogDelegate,FBSDKSharingDelegate {
    
    var passingLevelLow:Int!
    var passingLevelHigh:Int!
    var passingTags:[String] = []
    

    var userId:String!
    var userName:String!
    
    var usersToChallenge:[String] = []
    var usersToChallengeScrollView:UserScrollView!
    var challengeScrollView:ChallengeScrollView!
    var gametype:GameType!
    var drawBorders:Bool = false
    
    var playButton:UIButton!
    var backButton = UIButton()
    var activityLabel:UILabel!
    var addRandomUserButton:UIButton!
    //var inviteFriendsButton:UIButton!
    var titleLabel:UILabel!
    var numOfQuestionsForRound:Int!

    var challengeIdsCommaSeparated:String!
    
    var activityIndicator:UIActivityIndicatorView!
    
    var client: MSClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 40, 50))
        activityLabel.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        activityLabel.textAlignment = NSTextAlignment.Center
        activityLabel.adjustsFontSizeToFitWidth = true
        activityLabel.alpha = 0
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = CGRect(x: 0,y:0, width: 50, height: 50)
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityLabel)
        view.addSubview(activityIndicator)
        
        self.client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {

            // User is already logged in, do work such as go to next view controller.
            //self.performSegueWithIdentifier("segueFromLoginToPlay", sender: nil)
            activityLabel.text = "Loading.."
            activityLabel.alpha = 1
            activityIndicator.startAnimating()
            
            initUserData({() -> Void in
                if self.gametype == GameType.makingChallenge
                {
                    self.initUserFriends()
                }
                if self.gametype == GameType.takingChallenge
                {
                    self.initChallenges()
                }
            })
            
            
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
        backButton.layer.masksToBounds = true
        backButton.setTitle("🔙", forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(ChallengeViewController.backAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)

    }
    
    override func viewDidLayoutSubviews() {

    }
    
    func reloadMarks(tags:[String])
    {
       self.usersToChallenge = tags
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
            let alert = UIAlertView(title: "Facebook login error", message: "Something went wrong at login. Try again later", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            logOut()
        }
        else if result.isCancelled {
            // Handle cancellations
            logOut()
        }
        else {
            activityLabel.alpha = 1
            activityLabel.text = "Loading.."
            activityIndicator.startAnimating()
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("user_friends")
            {
                // Do work
                initUserData({() -> Void in
                    if self.gametype == GameType.makingChallenge
                    {
                        self.initUserFriends()
                    }
                    if self.gametype == GameType.takingChallenge
                    {
                        self.initChallenges()
                    }
                })
                
            }
            else
            {
                let alert = UIAlertView(title: "Friendslist", message: "Friendslist must be premitted to play against friends", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                logOut()
            }
            
            
        }
    }
    
    
    func logOut()
    {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        self.performSegueWithIdentifier("segueFromChallengeToMainMenu", sender: nil)
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        self.logOut()
    }

    
    func initUserData(completion: (() -> (Void)))
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                completion()
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

                result
                (UIApplication.sharedApplication().delegate as! AppDelegate).backgroundThread(background: {
                    self.updateUser({() -> Void in
                        
                        //self.activityLabel.alpha = 0
                        //self.activityIndicator.stopAnimating()
                        //completion()
                    })
                    
                })
                self.activityLabel.alpha = 0
                self.activityIndicator.stopAnimating()
                completion()
            }
        })
    }
    
    func initUserFriends()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                
                let reportError = (UIApplication.sharedApplication().delegate as! AppDelegate).reportErrorHandler
                let alertController = reportError?.alertController("\(error)")
                self.presentViewController(alertController!,
                    animated: true,
                    completion: nil)
                
            }
            else
            {
                print("fetched friends result: \(result)")
                let friendObjects = result.valueForKey("data") as! [NSDictionary]
                self.initForNewChallenge(friendObjects)

                result
            }
        })
    }
    
    func initCommonElements(margin:CGFloat,elementWidth:CGFloat,elementHeight:CGFloat)
    {
        titleLabel = UILabel(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width / 2) - (elementWidth / 2), margin, elementWidth, elementHeight))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.boldSystemFontOfSize(24)
        titleLabel.adjustsFontSizeToFitWidth = true        
        
        self.playButton = UIButton(frame:CGRectMake(titleLabel.frame.minX, UIScreen.mainScreen().bounds.size.height - margin - elementHeight, elementWidth , elementHeight))
        self.playButton.addTarget(self, action: #selector(ChallengeViewController.playAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.playButton.backgroundColor = UIColor.blueColor()
        self.playButton.layer.cornerRadius = 5
        self.playButton.layer.masksToBounds = true
        self.playButton.setTitle("Play", forState: UIControlState.Normal)
    }
    
    func initForNewChallenge(friendObjects:[NSDictionary])
    {
        var initialValues:[String:String] = [:]
        for friendObject in friendObjects {
            initialValues.updateValue(friendObject.valueForKey("id") as! String, forKey: friendObject.valueForKey("name") as! String )
        }

        let minNumberOfItemsOnGamerecordRow = 6
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        datactrl.loadGameData()
        for record in datactrl.gameResultsValues
        {
            let arrayOfValues = record.componentsSeparatedByString(",")
            if arrayOfValues.count == minNumberOfItemsOnGamerecordRow
            {

                
                let name = arrayOfValues[GlobalConstants.indexOfOpponentNameInGamerecordRow]
                let opponentId = arrayOfValues[GlobalConstants.indexOfOpponentIdInGamerecordRow]
                
                var found = false
                for item in initialValues
                {
                    if item.1 == opponentId
                    {
                        found = true
                        break;
                    }
                }
                
                
                if !found
                {
                    initialValues.updateValue(opponentId,forKey: name)
                }
            }
        }

        let margin:CGFloat = 10
        let elementWidth:CGFloat = 200
        let elementHeight:CGFloat = 60

        self.initCommonElements(margin,elementWidth: elementWidth,elementHeight: elementHeight)
        
        titleLabel.text = "Challenge users"
        
        /*
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string:"https://www.facebook.com/FacebookDevelopers")
        let inviteFriendsButton = FBSDKShareButton()
        inviteFriendsButton.shareContent = content
        inviteFriendsButton.frame = CGRectMake(titleLabel.frame.minX, playButton.frame.minY - (margin * 2) - (elementHeight * 2), elementWidth , elementHeight)
        */
        
        
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://itunes.apple.com/no/app/geo-feud/id1054226772?mt=8")
        content.imageURL = NSURL(string: "https://fbcdn-photos-h-a.akamaihd.net/hphotos-ak-xtp1/t39.2081-0/p128x128/12057212_936552496419899_597891191_n.png")
        content.contentDescription = "Test this iOS geography game"
        content.contentTitle = "Map feud"
        
        let inviteFriendsButton = FBSDKSendButton()
        inviteFriendsButton.frame = CGRectMake(titleLabel.frame.minX, playButton.frame.minY - (margin * 2) - (elementHeight * 2), elementWidth , elementHeight)
        inviteFriendsButton.shareContent = content
        //self.inviteFriendsButton.addTarget(self, action: "inviteFriendsAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        //self.inviteFriendsButton.backgroundColor = UIColor.blueColor()
        inviteFriendsButton.layer.cornerRadius = 5
        inviteFriendsButton.layer.masksToBounds = true
        inviteFriendsButton.setTitle("Invite friends", forState: UIControlState.Normal)
        
        addRandomUserButton = UIButton(frame:CGRectMake(titleLabel.frame.minX, playButton.frame.minY - margin - elementHeight, elementWidth , elementHeight))
        self.addRandomUserButton.addTarget(self, action: #selector(ChallengeViewController.addRandomUserAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.addRandomUserButton.backgroundColor = UIColor.blueColor()
        self.addRandomUserButton.layer.cornerRadius = 5
        self.addRandomUserButton.layer.masksToBounds = true
        self.addRandomUserButton.setTitle("Add random user", forState: UIControlState.Normal)

        
        let scrollViewHeight =  inviteFriendsButton.frame.minY - titleLabel.frame.maxY - ( margin * 2 )
        let scrollViewWidth = UIScreen.mainScreen().bounds.size.width - (margin * 2)
        self.usersToChallengeScrollView = UserScrollView(frame: CGRectMake(margin , titleLabel.frame.maxY + margin, scrollViewWidth, scrollViewHeight),initialValues:initialValues, itemsChecked:false)
        self.usersToChallengeScrollView.delegate = self
        self.usersToChallengeScrollView.alpha = 1
        
        view.addSubview(titleLabel)
        view.addSubview(playButton)
        view.addSubview(inviteFriendsButton)
        //view.addSubview(backButton)
        view.addSubview(addRandomUserButton)
        view.addSubview(usersToChallengeScrollView)
        self.view.bringSubviewToFront(activityLabel)
        self.view.bringSubviewToFront(activityIndicator)
        
        if friendObjects.count == 0
        {
            
            addRandomUser( {() -> Void in
                self.activityLabel.alpha = 1
                self.activityLabel.text = "No facebook friends with this app😢"
            })
        }
        else
        {
            activityLabel.alpha = 0
        }
        
        
    }
    
    
    func initChallenges()
    {
        
        let margin:CGFloat = 10
        let elementWidth:CGFloat = 200
        let elementHeight:CGFloat = 60

        self.initCommonElements(margin,elementWidth: elementWidth,elementHeight: elementHeight)
        
        titleLabel.text = "Pick a challenge"
        activityLabel.text = "Collecting challenges..."
        activityIndicator.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        let scrollViewHeight =  playButton.frame.minY - titleLabel.frame.maxY - ( margin * 2 )
        let scrollViewWidth = UIScreen.mainScreen().bounds.size.width - (margin * 2)
        self.challengeScrollView = ChallengeScrollView(frame: CGRectMake(margin , titleLabel.frame.maxY + margin, scrollViewWidth, scrollViewHeight))
        //self.challengeScrollView.delegate = self
        self.challengeScrollView.alpha = 1
        
        view.addSubview(titleLabel)
        playButton.alpha = 0
        view.addSubview(playButton)
        view.addSubview(backButton)
        view.addSubview(challengeScrollView)
        view.addSubview(activityLabel)
        view.addSubview(activityIndicator)
        
        
        self.requestChallenges()
        

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
            if response != nil
            {
                print("\(response)")
            }
            
            completionClosure()
        })
    }
    
    func requestChallenges()
    {
        let jsonDictionary = ["fbid":userId]
        //var jsonDictionary = ["fbid":"10155943015600858","name":userName]
        
        self.client!.invokeAPI("challenge", data: nil, HTTPMethod: "GET", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
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
                
                //Note ! root json object is not a dictionary but an array
                
                do{
                    let jsonArray = try NSJSONSerialization.JSONObjectWithData(result, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                    
                    if let array = jsonArray
                    {
                        for item in array {
                            print("item : \(item)")
                            if let jsonDictionary = item as? NSDictionary {
                                let title = jsonDictionary["title"] as! String
                                self.challengeScrollView.addItem(title,value: jsonDictionary)
                                
                                self.activityLabel.alpha = 0
                                self.playButton.alpha = 1
                            }
                        }
                        if jsonArray?.count == 0
                        {
                            self.activityLabel.alpha = 1
                            self.activityLabel.text = "No pending challenges from other users😒"
                        }
                        
                    }
                }
                catch
                {
                    self.activityLabel.text = "\(error)"
                }
                self.activityIndicator.stopAnimating()
                
                
            }
            if response != nil
            {
                print("\(response)")
            }
            
        })
    }
    

    var randomUsersAdded = 0
    func addRandomUserAction()
    {
        self.addRandomUser(nil)
    }
    
    //OBSOLETE
    func inviteFriendsAction()
    {
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://itunes.apple.com/no/app/geo-feud/id1054226772?mt=8")
        content.imageURL = NSURL(string: "https://itunes.apple.com/no/app/year-feud/id1050347083?mt=8")
        content.contentDescription = "bla bla description"
        content.contentTitle = "bla bla title"
        
        let messageDialog = FBSDKMessageDialog()
        messageDialog.delegate = self
        messageDialog.shareContent = content
        
        if messageDialog.canShow()
        {
            messageDialog.show()
        }
        else
        {
            var message = "Facebook messenger not installed"
            if UIDevice.currentDevice().model == "IPad"
            {
                message = "Cant redirect to messenger from IPad"
            }

            let alert = UIAlertView(title: "\(UIDevice.currentDevice().model) Could not send invite", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        let temp = results
        for item in temp
        {
            print(item)
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //TODO
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
    }
    
    func addRandomUser(completionClosure: (() -> Void)?)
    {
        activityLabel.alpha = 1
        activityLabel.text = "Collecting random user..."
        randomUsersAdded += 1
        if randomUsersAdded > 1
        {
            activityLabel.alpha = 0
            addRandomUserButton.alpha = 0
        }
        var userUsed:String = usersToChallengeScrollView.getAllItemsValueAsStringFormat()
        userUsed = "\(userUsed)\(self.userId)"
        
        let jsonDictionary = ["fbid":userId,"name":userName,"usedusers":userUsed]
        
        self.client!.invokeAPI("randomuser", data: nil, HTTPMethod: "GET", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
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
                //Note ! root json object is not a dictionary but an array

                do {
                    let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(result, options: [])
                    if let jsonDictionary = json as? NSDictionary { // Check 3
                        print("Dictionary received")
                        let name = jsonDictionary["name"] as! String
                        let fbId = jsonDictionary["fbid"] as! String
                        self.usersToChallengeScrollView.addItem("\(name) (random user)", value: fbId)
                    }
                } catch let error as NSError {
                    print(error)
                } catch {
                    fatalError()
                }
                
            }
            if response != nil
            {
                print("\(response)")
            }
            self.activityLabel.alpha = 0
            completionClosure?()
        })
    }
    
    var questionIds:String?
    var challengeName:String!
    func sendChallengeMakingStart()
    {
        let borders:String = drawBorders ? "1" : "0"
        let firstNameInUserName = userName.componentsSeparatedByString(" ").count > 1 ? userName.componentsSeparatedByString(" ").first : userName
        let borderString = drawBorders ? "bord." : "no bord."
        challengeName = "\(passingLevelLow)-\(passingLevelHigh) \((borderString)) from \(firstNameInUserName)"
        questionIds = questionsToCommaseparated()
        let toIds:String = usersToCommaseparated()
        
        print("fbid:\(userId) chname:\(challengeName) toIdsPar:\(toIds) questionIds:\(questionIds)")

        let jsonDictionary = ["fbid":userId,"chname":challengeName,"toIdsPar":toIds,"questionIdsPar":questionIds,"borders":borders]
        
        self.client!.invokeAPI("startmakingchallenge", data: nil, HTTPMethod: "POST", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
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
                print(result)
                ///backstabbing cock!!!.. is there really no way of escaping double quotes directly from json string...
                
                let temp = NSString(data: result, encoding:NSUTF8StringEncoding) as! String
                self.challengeIdsCommaSeparated = String(temp.characters.dropLast().dropFirst())
                
                self.performSegueWithIdentifier("segueFromChallengeToPlay", sender: nil)
            }
            if response != nil
            {
                print("\(response)")
            }

        })
        
    }
    
    func sendChallengeTakenStart()
    {

        let values = self.challengeScrollView.getSelectedValue()
        let challengeId = values!["challengeId"] as! String

        print("challengeId:\(challengeId)")
        let jsonDictionary = ["chid":challengeId]
        
        self.client!.invokeAPI("starttakingchallenge", data: nil, HTTPMethod: "POST", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
            
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
                
                print(result)
                self.performSegueWithIdentifier("segueFromChallengeToPlay", sender: nil)
            }
            if response != nil
            {
                print("\(response)")
            }
            
            
        })
    }
    
    func usersToCommaseparated() -> String
    {
        var returnString:String = ""
        for item in usersToChallenge
        {
            returnString += item + ","
            
        }
        return String(returnString.characters.dropLast())
    }
    
    func questionsToCommaseparated() -> String
    {
        let datactrl = (UIApplication.sharedApplication().delegate as! AppDelegate).datactrl
        let questonIds = datactrl.getXNumberOfQuestionIds(numOfQuestionsForRound)

        var returnString:String = ""
        for questionId in questonIds
        {
            returnString += questionId + ","
        }
        return String(returnString.characters.dropLast())
        
    }
    
    func playAction()
    {
        self.playButton.userInteractionEnabled = false
        if self.gametype == GameType.makingChallenge
        {
            usersToChallenge = self.usersToChallengeScrollView.getCheckedItemsValueAsArray()
            
            if usersToChallenge.count < 1
            {
                let alert = UIAlertView(title: "Pick 1", message: "Select at least 1 user", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.playButton.userInteractionEnabled = true
            }
            else
            {
                self.view.bringSubviewToFront(activityLabel)
                self.view.bringSubviewToFront(activityIndicator)
                activityIndicator.startAnimating()
                self.activityLabel.text = "Loading game.."
                sendChallengeMakingStart()
                //self.performSegueWithIdentifier("segueFromChallengeToPlay", sender: nil)
            }
        }
        else if self.gametype == GameType.takingChallenge
        {
            let selectedValue = challengeScrollView.getSelectedValue()
            if selectedValue == nil
            {
                let alert = UIAlertView(title: "Pick 1", message: "Select a challenge", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.playButton.userInteractionEnabled = true

            }
            else
            {
                self.view.bringSubviewToFront(activityLabel)
                self.view.bringSubviewToFront(activityIndicator)
                activityIndicator.startAnimating()
                self.activityLabel.text = "Loading game.."
                sendChallengeTakenStart()
                //self.performSegueWithIdentifier("segueFromChallengeToPlay", sender: nil)
            }
        }
        
    }
    
    func backAction()
    {
        self.performSegueWithIdentifier("segueFromChallengeToMainMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "segueFromChallengeToPlay") {

            self.activityIndicator.stopAnimating()
            let svc = segue!.destinationViewController as! PlayViewController

            svc.gametype = gametype
            if self.gametype == GameType.makingChallenge
            {

                svc.drawBorders = drawBorders
                let makingChallenge = MakingChallenge(challengesName: challengeName,users:usersToChallenge, questionIds: questionIds!.componentsSeparatedByString(","), challengeIds: challengeIdsCommaSeparated!)
                svc.challenge = makingChallenge
                //questionIds
                //questionIds
            }
            else if self.gametype == GameType.takingChallenge
            {
                let values = self.challengeScrollView.getSelectedValue()
                svc.challenge = TakingChallenge(values: values!)
            }
            
            svc.myIdAndName = (self.userId,self.userName)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}