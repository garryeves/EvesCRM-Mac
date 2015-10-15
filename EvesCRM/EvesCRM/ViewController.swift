//
//  ViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 6/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        myID = "dummy" // this is here for when I enable multiuser, to make it easy to implement
        
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("performInitialSync"), userInfo: nil, repeats: false)

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func performInitialSync()
    {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("initialPopulationOfTables"), userInfo: nil, repeats: false)
        myDBSync.sync()
    }
    
    func DBUpdateMessage(notification: NSNotification)
    {
        let workingText = notification.userInfo!["displayMessage"] as! String
        NSLog("working text = \(workingText)")
    }
    
    func initialPopulationOfTables()
    {
        var decodeString: String = ""
        
        //  For testing purposes, this will remove all the teams and GTD levels
        // myDatabaseConnection.deleteAllTeams()
        
        if myDatabaseConnection.getTeamsCount() == 0
        {
            let myNewTeam = team()
            myNewTeam.name = "My Life"
            myNewTeam.type = "private"
            myNewTeam.status = "Open"
            
            // Store the ID for the default team
            myDatabaseConnection.updateDecodeValue("Default Team", inCodeValue: "\(myNewTeam.teamID)", inCodeType: "hidden")
            
            myCurrentTeam = myNewTeam
        }
        else
        {
            // Load up the default team
            
            decodeString = myDatabaseConnection.getDecodeValue("Default Team")
            
            let tempID = Int(decodeString)
            
            if tempID == nil
            {
                myCurrentTeam = team(inTeamID: 1)
            }
            else
            {
                myCurrentTeam = team(inTeamID: tempID!)
            }
        }
        
        //  For testing purposes, this will reset decodes
        // myDatabaseConnection.tidyDecodes()
        //      myDatabaseConnection.resetDecodes()
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks before current date", inCodeValue: "1", inCodeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks after current date", inCodeValue: "4", inCodeType: "stepper")
        }
        
        let myStart = self.storyboard?.instantiateControllerWithIdentifier("macStartViewController") as! macStartViewController
        
        view.window?.contentViewController = myStart
        
   //     self.presentViewController(myStart, animated: true, completion: nil)
    }
}

