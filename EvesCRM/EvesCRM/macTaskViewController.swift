//
//  macTaskViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

protocol MyTaskDelegate
{
    func myTaskDidFinish(table: String)
}

class macTaskViewController: NSViewController, NSTextViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate
{
    @IBOutlet weak var txtTitle: NSTextField!
    @IBOutlet weak var txtRepeatEvery: NSTextField!
    @IBOutlet weak var txtEstTime: NSTextField!
    @IBOutlet weak var txtUpdateSource: NSTextField!
    @IBOutlet var txtDescription: NSTextView!
    @IBOutlet weak var colContexts: NSCollectionView!
    @IBOutlet weak var colUpdates: NSCollectionView!
    @IBOutlet var txtUpdateDetails: NSTextView!
    @IBOutlet weak var btnProject: NSPopUpButton!
    @IBOutlet weak var btnStatus: NSPopUpButton!
    @IBOutlet weak var btnRepeatPeriod: NSPopUpButton!
    @IBOutlet weak var btnRepeatBase: NSPopUpButton!
    @IBOutlet weak var btnTimeInterval: NSPopUpButton!
    @IBOutlet weak var btnPriority: NSPopUpButton!
    @IBOutlet weak var btnUrgency: NSPopUpButton!
    @IBOutlet weak var btnEnergy: NSPopUpButton!
    @IBOutlet weak var btnAddContext: NSButton!
    @IBOutlet weak var btnAddUpdate: NSButton!
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var btnAddPerson: NSPopUpButton!
    @IBOutlet weak var btnAddPlace: NSPopUpButton!
    @IBOutlet weak var btnAddTool: NSPopUpButton!
    
    var delegate: MyTaskDelegate?
    var passedTask: task!
    var table: String!  = ""
    
    private var myProjectID: Int = 0
    private var myProjectDetails: [Projects] = Array()
    private var txtDescriptionChanged: Bool = false
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        
        delegate?.myTaskDidFinish(table)
    }
    
    override func viewWillDisappear()
    {
        super.viewWillDisappear()
        
        if txtDescriptionChanged
        {
            passedTask.details = txtDescription.string!
        }
        
        passedTask.title = txtTitle.stringValue
        passedTask.repeatInterval = Int(txtRepeatEvery.stringValue)!
        passedTask.estimatedTime = Int(txtEstTime.stringValue)!
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupPopupValues()
        
        colContexts.dataSource = self
        colUpdates.dataSource = self
        
        colContexts.delegate = self
        colUpdates.delegate = self
        
        let minSize = NSMakeSize(0,0)
        colContexts.maxItemSize = minSize
        colUpdates.maxItemSize = minSize
        
        if passedTask.taskID != 0
        {
            // Lets load up the fields
            txtTitle.stringValue = passedTask.title
            txtDescription.string = passedTask.details
            
            if passedTask.displayDueDate == ""
            {
                endDatePicker.stringValue = ""
            }
            else
            {
                endDatePicker.dateValue = passedTask.dueDate
            }
            
            if passedTask.displayStartDate == ""
            {
                startDatePicker.stringValue = ""
            }
            else
            {
                startDatePicker.dateValue = passedTask.startDate
            }
            
            if passedTask.status == ""
            {
                btnStatus.setTitle("Open")
            }
            else
            {
                btnStatus.setTitle(passedTask.status)
            }
            
            if passedTask.priority == ""
            {
                btnPriority.setTitle("Click to set")
            }
            else
            {
                btnPriority.setTitle(passedTask.priority)
            }
            
            if passedTask.energyLevel == ""
            {
                btnEnergy.setTitle("Click to set")
            }
            else
            {
                btnEnergy.setTitle(passedTask.energyLevel)
            }
            
            if passedTask.urgency == ""
            {
                btnUrgency.setTitle("Click to set")
            }
            else
            {
                btnUrgency.setTitle(passedTask.urgency)
            }
            
            
            if passedTask.estimatedTimeType == ""
            {
                btnTimeInterval.setTitle("Click to set")
            }
            else
            {
                btnTimeInterval.setTitle(passedTask.estimatedTimeType)
            }
            
            if passedTask.projectID == 0
            {
                btnProject.setTitle("Click to set")
            }
            else
            {
                // Go an get the project name
                getProjectName(passedTask.projectID)
            }
            
            if passedTask.repeatType == ""
            {
                btnRepeatPeriod.setTitle("Set Period")
            }
            else
            {
                btnRepeatPeriod.setTitle(passedTask.repeatType)
            }
            
            if passedTask.repeatBase == ""
            {
                btnRepeatBase.setTitle("Set Base")
            }
            else
            {
                btnRepeatBase.setTitle(passedTask.repeatBase)
            }
            
            txtRepeatEvery.stringValue = "\(passedTask.repeatInterval)"
            txtEstTime.stringValue = "\(passedTask.estimatedTime)"

            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTaskContext:", name:"NotificationRemoveTaskContext", object: nil)
        }
    }
    
    override var representedObject: AnyObject?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if collectionView == colContexts
        {
            retVal = passedTask.contexts.count
        }
        else
        {
            retVal = passedTask.history.count
        }

        return retVal
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem
    {
        if collectionView == colContexts
        {
            var myCell: TaskContextObject!
            myCell = TaskContextObject(title: passedTask.contexts[indexPath.item].name, workingContext: passedTask.contexts[indexPath.item])
            
            let cellView = collectionView.makeItemWithIdentifier("taskContextItem", forIndexPath: indexPath)
            
            if (indexPath.item % 2 == 0)
            {
                myCell.cellColor = myRowColour
            }
            else
            {
                myCell.cellColor = CGColorGetConstantColor(kCGColorClear)
            }
            
            cellView.representedObject = myCell
            
            let mySize = NSSize(width: collectionView.frame.width, height: CGFloat(17))
            cellView.preferredContentSize = mySize
            
            return cellView
        }
        else
        {
            var myCell: TaskUpdateObject!
            myCell = TaskUpdateObject(title: passedTask.history[indexPath.item].details, source: passedTask.history[indexPath.item].source, updateDate: passedTask.history[indexPath.item].displayShortUpdateDate, updateTime: passedTask.history[indexPath.item].displayShortUpdateTime)
         
            let cellView = collectionView.makeItemWithIdentifier("taskUpdateItem", forIndexPath: indexPath)
            
            if (indexPath.item % 2 == 0)
            {
                myCell.cellColor = myRowColour
            }
            else
            {
                myCell.cellColor = CGColorGetConstantColor(kCGColorClear)
            }
            
            cellView.representedObject = myCell
            
            let mySize = NSSize(width: collectionView.frame.width, height: CGFloat(50))
            cellView.preferredContentSize = mySize

            return cellView
        }
    }
    
    func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize
    {
        var retVal: NSSize!
        
        var rows: Int = 0
        
        if collectionView == colContexts
        {
            rows = passedTask.contexts[indexPath.item].name.componentsSeparatedByString("\n").count
            retVal = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 21))
        }
        else // if collectionView == collection4
        {
            rows = passedTask.history[indexPath.item].details.componentsSeparatedByString("\n").count
            retVal = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 21) + 21)
        }
        
        return retVal
    }

        
    @IBAction func txtTitle(sender: NSTextField)
    {
        if txtTitle.stringValue != ""
        {
            passedTask.title = txtTitle.stringValue
        }
    }
    
    @IBAction func txtRepeatEvery(sender: NSTextField)
    {
        passedTask.repeatInterval = Int(txtRepeatEvery.stringValue)!
    }
    
    @IBAction func txtEstTime(sender: NSTextField)
    {
        passedTask.estimatedTime = Int(txtEstTime.stringValue)!
    }
    
    @IBAction func btnProject(sender: NSPopUpButton)
    {
        if sender.indexOfSelectedItem > 0
        {
            passedTask.projectID = myProjectDetails[sender.indexOfSelectedItem - 1].projectID as Int
        }
    }
    
    @IBAction func btnStatus(sender: NSPopUpButton)
    {
        passedTask.status = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnRepeatPeriod(sender: NSPopUpButton)
    {
        passedTask.repeatType = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnRepeatBase(sender: NSPopUpButton)
    {
        passedTask.repeatBase = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnTimeInterval(sender: NSPopUpButton)
    {
        passedTask.estimatedTimeType = sender.titleOfSelectedItem!
    }

    @IBAction func btnPriority(sender: NSPopUpButton)
    {
        passedTask.priority = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnUrgency(sender: NSPopUpButton)
    {
        passedTask.urgency = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnEnergy(sender: NSPopUpButton)
    {
       passedTask.energyLevel = sender.titleOfSelectedItem!
    }
    
    @IBAction func btnAddContext(sender: NSButton)
    {
    }
    
    @IBAction func btnAddUpdate(sender: NSButton)
    {
        if txtUpdateDetails.string != "" && txtUpdateSource.stringValue != ""
        {
            passedTask.addHistoryRecord(txtUpdateDetails.string!, inHistorySource: txtUpdateSource.stringValue)
            txtUpdateDetails.string = ""
            txtUpdateSource.stringValue = ""
            colUpdates.reloadData()
        }
        else
        {
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "Add Task Update"
            myPopup.informativeText = "You need to enter update details and source"
            myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
            myPopup.addButtonWithTitle("OK")

            let _ = myPopup.runModal()
        }

    }

    func textDidChange(notification: NSNotification)
    { //Handle the text changes here
        txtDescriptionChanged = true
    }

    func textDidEndEditing(notification: NSNotification)
    { //Handle the text changes here
        passedTask.details = txtDescription.string!
        txtDescriptionChanged = false
    }
    
    @IBAction func startDatePicker(sender: NSDatePicker)
    {
        passedTask.startDate = startDatePicker.dateValue
    }
    
    @IBAction func endDatePicker(sender: NSDatePicker)
    {
        passedTask.dueDate = endDatePicker.dateValue
    }
    
    @IBAction func btnAddPerson(sender: NSPopUpButton)
    {
        if sender.indexOfSelectedItem > 0
        {
            let myContexts = contexts()

            passedTask.addContext(myContexts.people[sender.indexOfSelectedItem - 1].contextID)
        
            // Reload the collection data
        
            colContexts.reloadData()
        }
    }
    
    @IBAction func btnAddPlace(sender: NSPopUpButton)
    {
        if sender.indexOfSelectedItem > 0
        {
            let myContexts = contexts()
        
            passedTask.addContext(myContexts.places[sender.indexOfSelectedItem - 1].contextID)
        
            // Reload the collection data
        
            colContexts.reloadData()
        }
    }
    
    @IBAction func btnAddTool(sender: NSPopUpButton)
    {
        if sender.indexOfSelectedItem > 0
        {
            let myContexts = contexts()
        
            passedTask.addContext(myContexts.tools[sender.indexOfSelectedItem - 1].contextID)
        
            // Reload the collection data
        
            colContexts.reloadData()
        }
    }
    
    func getProjectName(projectID: Int)
    {
        let myProjects = myDatabaseConnection.getProjectDetails(projectID)
        
        if myProjects.count == 0
        {
            btnProject.setTitle("Click to set")
            myProjectID = 0
        }
        else
        {
            btnProject.setTitle(myProjects[0].projectName)
            myProjectID = myProjects[0].projectID as Int
        }
    }
    
    func setupPopupValues()
    {
        btnStatus.removeAllItems()
        btnTimeInterval.removeAllItems()
        btnPriority.removeAllItems()
        btnUrgency.removeAllItems()
        btnEnergy.removeAllItems()
        btnRepeatPeriod.removeAllItems()
        btnRepeatBase.removeAllItems()
        btnProject.removeAllItems()
        btnAddPerson.removeAllItems()
        btnAddPlace.removeAllItems()
        btnAddTool.removeAllItems()

        for myItem in myTaskStatus
        {
            btnStatus.addItemWithTitle(myItem)
        }
        
        for myItem in myTimeInterval
        {
            btnTimeInterval.addItemWithTitle(myItem)
        }
        
        for myItem in myTaskPriority
        {
            btnPriority.addItemWithTitle(myItem)
        }
        
        for myItem in myTaskUrgency
        {
            btnUrgency.addItemWithTitle(myItem)
        }
        
        for myItem in myTaskEnergy
        {
            btnEnergy.addItemWithTitle(myItem)
        }
        
        for myItem in myRepeatPeriods
        {
            btnRepeatPeriod.addItemWithTitle(myItem)
        }

        for myItem in myRepeatBases
        {
            btnRepeatBase.addItemWithTitle(myItem)
        }

        btnProject.addItemWithTitle("")
            
        // Get the projects for the tasks current team ID
        let myProjects = myDatabaseConnection.getProjects(passedTask.teamID)
            
        for myProject in myProjects
        {
            btnProject.addItemWithTitle(myProject.projectName)
            myProjectDetails.append(myProject)
        }
            
        // Now also add in the users projects for other team Ids they have access to
            
        for myTeamItem in myDatabaseConnection.getMyTeams(myID)
        {
            if myTeamItem.teamID as Int != passedTask.teamID
            {
                let myProjects = myDatabaseConnection.getProjects(myTeamItem.teamID as Int)
                for myProject in myProjects
                {
                    btnProject.addItemWithTitle(myProject.projectName)
                    myProjectDetails.append(myProject)
                }
            }
        }
        
        let myContexts = contexts()
        
        btnAddPerson.addItemWithTitle("")
        
        for myItem in myContexts.people
        {
            btnAddPerson.addItemWithTitle(myItem.name)
        }
        
        btnAddPlace.addItemWithTitle("")
        
        for myItem in myContexts.places
        {
            btnAddPlace.addItemWithTitle(myItem.name)
        }

        btnAddTool.addItemWithTitle("")
        
        for myItem in myContexts.tools
        {
            btnAddTool.addItemWithTitle(myItem.name)
        }
    }
    
    func removeTaskContext(notification: NSNotification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedTask.removeContext(contextToRemove)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
}

class TaskContextCollectionViewItemView: NSView
{
    var selected: Bool = false
        {
        didSet
        {
            if selected != oldValue
            {
                needsDisplay = true
            }
        }
    }
    var highlightState: NSCollectionViewItemHighlightState = .None
        {
        didSet
        {
            if highlightState != oldValue
            {
                needsDisplay = true
            }
        }
    }
    
    override var wantsUpdateLayer: Bool
        {
            return true
    }
    
    override func updateLayer()
    {
        layer!.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        wantsLayer = true
        layer?.masksToBounds = true
    }
}

class TaskContextObject: NSObject
{
    var title:String
    var workingContext: context!
    var cellColor: CGColor!
    
    init(title:String, workingContext: context)
    {
        self.title = title
        self.workingContext = workingContext
    }
}

class TaskContextCollectionViewItem: NSCollectionViewItem
{
    var taskContextObject: TaskContextObject?
    {
        return representedObject as? TaskContextObject
    }
    
    override var selected: Bool
    {
        didSet
        {
            (self.view as! TaskContextCollectionViewItemView).selected = selected
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState
    {
        didSet
        {
            (self.view as! TaskContextCollectionViewItemView).highlightState = highlightState
        }
    }
    
    @IBOutlet weak var name: NSTextField!
    
     override func viewWillAppear()
    {
        name.setFrameSize(NSSize(width: collectionView.frame.width, height: CGFloat(17)))
        (self.view as! TaskContextCollectionViewItemView).layer!.backgroundColor = taskContextObject!.cellColor
    }
    
    @IBAction func btnRemove(sender: NSButton)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveTaskContext", object: nil, userInfo:["itemNo":taskContextObject!.workingContext.contextID])
    }
}

class TaskUpdateCollectionViewItemView: NSView
{
    var selected: Bool = false
    {
        didSet
        {
            if selected != oldValue
            {
                needsDisplay = true
            }
        }
    }
    var highlightState: NSCollectionViewItemHighlightState = .None
    {
        didSet
        {
            if highlightState != oldValue
            {
                needsDisplay = true
            }
        }
    }
    
    override var wantsUpdateLayer: Bool
    {
            return true
    }
    
    override func updateLayer()
    {
        layer!.backgroundColor = NSColor.whiteColor().CGColor
    }

    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        wantsLayer = true
        layer?.masksToBounds = true
    }
}

class TaskUpdateObject: NSObject
{
    var title:String
    var source:String
    var updateDateString:String
    var updateTimeString:String
    var cellColor: CGColor!
    
    init(title:String, source: String, updateDate: String, updateTime: String)
    {
        self.source = source
        self.title = title
        self.updateDateString = updateDate
        self.updateTimeString = updateTime
    }
}

class TaskUpdateCollectionViewItem: NSCollectionViewItem
{
    var taskUpdateObject: TaskUpdateObject?
    {
            return representedObject as? TaskUpdateObject
    }
    
    override var selected: Bool
    {
        didSet
        {
            (self.view as! TaskUpdateCollectionViewItemView).selected = selected
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState
    {
        didSet
        {
            (self.view as! TaskUpdateCollectionViewItemView).highlightState = highlightState
        }
    }

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var source: NSTextField!
    @IBOutlet weak var updateDateString: NSTextField!
    @IBOutlet weak var updateTimeString: NSTextField!
    
    override func viewWillAppear()
    {
        (self.view as! TaskUpdateCollectionViewItemView).layer!.backgroundColor = taskUpdateObject!.cellColor
    }
}


