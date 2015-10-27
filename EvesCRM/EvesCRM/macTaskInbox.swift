//
//  macTaskInbox.swift
//  EvesCRM
//
//  Created by Garry Eves on 27/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Cocoa

class macTaskInbox: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, MyTaskDelegate
{

    @IBOutlet weak var colTaskInbox: NSCollectionView!
    
    private var myTaskList: [task] = Array()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do view setup here.
        
        colTaskInbox.dataSource = self
        colTaskInbox.delegate = self
        
        let minSize = NSMakeSize(0,0)
        colTaskInbox.maxItemSize = minSize
        
        loadDataArray()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTaskCollection", name:"NotificationRemoveTaskInbox", object: nil)
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
        
        if collectionView == colTaskInbox
        {
            retVal = myTaskList.count
        }
        else
        {
            retVal = 0
        }
        
        return retVal
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem
    {
        if collectionView == colTaskInbox
        {
            var myCell: TaskInboxObject!
            myCell = TaskInboxObject(title: myTaskList[indexPath.item].title, workingTask: myTaskList[indexPath.item], storyboard: self.storyboard!, delegate: self, viewController: self)
            
            let cellView = collectionView.makeItemWithIdentifier("taskInboxItem", forIndexPath: indexPath)
            
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
            var myCell: TaskInboxObject!
            myCell = TaskInboxObject(title: myTaskList[indexPath.item].title, workingTask: myTaskList[indexPath.item], storyboard: self.storyboard!, delegate: self, viewController: self)
            
            let cellView = collectionView.makeItemWithIdentifier("taskInboxItem", forIndexPath: indexPath)
            
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
        
        if collectionView == colTaskInbox
        {
            rows = myTaskList[indexPath.item].title.componentsSeparatedByString("\n").count
        }
        else // if collectionView == collection4
        {
            rows = myTaskList[indexPath.item].title.componentsSeparatedByString("\n").count
        }
        
        retVal = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 31))
        
        return retVal
    }

    func loadDataArray()
    {
        // Get a list fo my teams
        myTaskList.removeAll()
        
        for myTeam in myDatabaseConnection.getMyTeams(myID)
        {
            // Get list of tasks without a Project
            
            let projectArray =  myDatabaseConnection.getTasksWithoutProject(myTeam.teamID as Int)
            
            // Get list of tasks without a context
            
            let contextArray = myDatabaseConnection.getTaskWithoutContext(myTeam.teamID as Int)
            
            
            for myProjectTask in projectArray
            {
                let tempTask = task(taskID: myProjectTask.taskID as Int)
                myTaskList.append(tempTask)
            }
            
            for myContextTask in contextArray
            {
                // parse through array of tasks from project to see if the task from context already exists, if it does then no action needed, if does not exist then add the task from context
                let tempTask = task(taskID: myContextTask.taskID as Int)
                
                var taskFound: Bool = false
                
                for myItem in myTaskList
                {
                    if myItem.taskID == tempTask.taskID
                    {
                        // Match found
                        taskFound = true
                        break
                    }
                }
                
                if !taskFound
                {
                    myTaskList.append(tempTask)
                }
            }
        }
    }
    
    func refreshTaskCollection()
    {
        loadDataArray()
        colTaskInbox.reloadData()
    }
    
    func myTaskDidFinish(table: String)
    {
        refreshTaskCollection()
    }
}

class TaskInboxCollectionViewItemView: NSView
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

class TaskInboxObject: NSObject
{
    var title:String
    var workingTask: task!
    var storyboard: NSStoryboard
    var taskDelegate: MyTaskDelegate
    var viewController: macTaskInbox
    var cellColor: CGColor!
    
    init(title:String, workingTask: task, storyboard: NSStoryboard, delegate: MyTaskDelegate, viewController: macTaskInbox)
    {
        self.title = title
        self.workingTask = workingTask
        self.storyboard = storyboard
        self.taskDelegate = delegate
        self.viewController = viewController
    }
    
    func dataCellClicked()
    {
        let tasksViewControl = storyboard.instantiateControllerWithIdentifier("macTaskViewController") as! macTaskViewController
        
        tasksViewControl.passedTask = workingTask
        tasksViewControl.delegate = taskDelegate
        
        viewController.presentViewControllerAsModalWindow(tasksViewControl)
    }

}

class TaskInboxCollectionViewItem: NSCollectionViewItem
{
    var taskInboxObject: TaskInboxObject?
    {
        return representedObject as? TaskInboxObject
    }
    
    override var selected: Bool
    {
        didSet
        {
            (self.view as! TaskInboxCollectionViewItemView).selected = selected
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState
    {
        didSet
        {
            (self.view as! TaskInboxCollectionViewItemView).highlightState = highlightState
        }
    }
    
    @IBOutlet weak var name: NSTextField!
    
    override func mouseDown(theEvent: NSEvent)
    {
        if theEvent.clickCount == 2
        {  // Do nothing
            //print("Double click \(labelObject!.title)")
        }
        else
        {
            super.mouseDown(theEvent)
            
            taskInboxObject?.dataCellClicked()
        }
    }
    
    override func viewWillAppear()
    {
        name.setFrameSize(NSSize(width: collectionView.frame.width, height: CGFloat(17)))
        
        (self.view as! TaskInboxCollectionViewItemView).layer!.backgroundColor = taskInboxObject!.cellColor
    }
    
    @IBAction func btnRemove(sender: NSButton)
    {
        taskInboxObject!.workingTask.status = "Complete"
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveTaskInbox", object: nil)
    }
}
