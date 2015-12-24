//
//  ReportErrorHandler.swift
//  MapFeud
//
//  Created by knut on 08/11/15.
//  Copyright © 2015 knut. All rights reserved.
//
import Foundation
import CoreData
import UIKit


class ReportErrorHandler
{
    let client: MSClient

    
    init()
    {
        
        client = (UIApplication.sharedApplication().delegate as! AppDelegate).client!
        /*
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year, fromDate: date)
        todaysYear = Double(components.year)
        */
        
    }
    
    func alertController(errorText:String) -> UIAlertController
    {

        let alertV = UIAlertController(title: "Server error 😲",
            message: "Sorry for the annoyance. Report and I´ll look into it",
            preferredStyle: .Alert)
        alertV.addAction(UIAlertAction(title: "Report",
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                self.reportError(errorText)
        }))
        alertV.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
        }))
        
        return alertV
        
    }
    
    func displayAlert(alert:UIAlertView)
    {
        alert.show()
    }


    func reportError(errortext:String, alert:UIAlertView? = nil)
    {
        alert?.show()

        (UIApplication.sharedApplication().delegate as! AppDelegate).backgroundThread(background: {
            let device = UIDevice.currentDevice()
            let deviceModel = device.model
            let systemName = device.systemName
            let systemVersion = device.systemVersion
            let deviceText = "\(deviceModel) \(systemName) \(systemVersion)"
            let jsonDictionary = ["error":errortext,"device":deviceText]
            self.client.invokeAPI("reporterror", data: nil, HTTPMethod: "POST", parameters: jsonDictionary, headers: nil, completion: {(result:NSData!, response: NSHTTPURLResponse!,error: NSError!) -> Void in
                
                if error != nil
                {
                    print("\(error)")
                }
                if result != nil
                {
                    print("\(result)")
                    
                }
                if response != nil
                {
                    print("\(response)")
                }
            })
        })
    }
}