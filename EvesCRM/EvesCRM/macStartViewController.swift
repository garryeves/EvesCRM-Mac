//
//  macStartViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 7/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation

import Cocoa
import AppKit
import EventKit
import Contacts

class macStartViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSCollectionViewDelegate, MyPopupDelegate, MyTaskDelegate
{
    @IBOutlet weak var OutlineView: NSOutlineView!
    
    @IBOutlet weak var lblHeader: NSTextField!
    @IBOutlet weak var btnAdd1: NSButton!
    @IBOutlet weak var btnAdd2: NSButton!
    @IBOutlet weak var btnAdd3: NSButton!
    @IBOutlet weak var btnAdd4: NSButton!
    @IBOutlet weak var collection1: NSCollectionView!
    @IBOutlet weak var collection2: NSCollectionView!
    @IBOutlet weak var collection3: NSCollectionView!
    @IBOutlet weak var collection4: NSCollectionView!
    @IBOutlet weak var btnMenu1: NSComboBox!
    @IBOutlet weak var btnMenu2: NSComboBox!
    @IBOutlet weak var btnMenu3: NSComboBox!
    @IBOutlet weak var btnMenu4: NSComboBox!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var btnSetDate: NSButton!
    @IBOutlet weak var colScroll1: NSScrollView!
    @IBOutlet weak var colScroll2: NSScrollView!
    @IBOutlet weak var colScroll3: NSScrollView!
    @IBOutlet weak var colScroll4: NSScrollView!
    
    var headerArray: [menuObjectMac] = Array()
    
    var table1Contents:[TableData] = [TableData]()
    var table2Contents:[TableData] = [TableData]()
    var table3Contents:[TableData] = [TableData]()
    var table4Contents:[TableData] = [TableData]()
  
    var menu1Options: [String]!
    var menu2Options: [String]!
    var menu3Options: [String]!
    var menu4Options: [String]!
    
    var itemSelected = "Details"
    var TableOptions: [String]!
    
    
    // store the details of the person selected in the People table
    var personContact: iOSContact!
    var mySelectedProject: project!
    var myDisplayType: String = ""
    var myContextName: String = ""
    var eventDetails: iOSCalendar!
    var reminderDetails: iOSReminder!
    var projectMemberArray: [String] = Array()
    var myTaskItems: [task] = Array()
    
    var myWorkingTask: task!
    var myWorkingTable: String = ""
    var reBuildTableName: String = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        myID = "dummy" // this is here for when I enable multiuser, to make it easy to implement
        
// temp comment out until have more of app ready        myDBSync.startTimer()
                
        connectCalendar()
        
        createAddressBook()
        determineAddressBookStatus()
        
        menu1Options = populateMenu()
        menu2Options = populateMenu()
        menu3Options = populateMenu()
        menu4Options = populateMenu()

        btnMenu1.reloadData()
        btnMenu2.reloadData()
        btnMenu3.reloadData()
        btnMenu4.reloadData()
        
        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: "Calendar")
        itemSelected = "Calendar"
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: "Details")
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: "Project Membership")
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: "Tasks")

        TableOptions = Array()
        
        collection1.dataSource = self
        collection2.dataSource = self
        collection3.dataSource = self
        collection4.dataSource = self
        
        collection1.delegate = self
        collection2.delegate = self
        collection3.delegate = self
        collection4.delegate = self
        
        let minSize = NSMakeSize(0,0)
        
        collection1.maxItemSize = minSize
        collection2.maxItemSize = minSize
        collection3.maxItemSize = minSize
        collection4.maxItemSize = minSize
        
        
        
        
        // Do any additional setup after loading the view.
        hideFields()
        
        buildSidebar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "outlineViewChanged:", name:"NSOutlineViewSelectionDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataCellClicked:", name:"NSDataCellClickedNotification", object: nil)

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject
    {
        if item == nil
        {
            let myItem = headerArray[index]
            return myItem
        }
        else
        {
            let myItem = item as! menuObjectMac
            
            return myItem.array[index]
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool
    {
        if item.isKindOfClass(menuObjectMac)
        {
            let myItem = item as! menuObjectMac
            
            if myItem.array.count > 0
            {
                return true
            }
        }
        
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int
    {
        if let myItem = item as? menuObjectMac
        {
            return myItem.array.count
        }
        else
        {
            return headerArray.count
        }
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn: NSTableColumn?, byItem:AnyObject?) -> AnyObject?
    {
        let myItem = byItem as! menuObjectMac
        
        return myItem.name

    }
    
    func outlineViewChanged(notification: NSNotification)
    {
        let object = OutlineView.itemAtRow(OutlineView.selectedRow)
        
        if object!.isKindOfClass(menuObjectMac)
        {
            let myItem = object as! menuObjectMac
            sideBarDidSelect(myItem)
        }
        else
        {
            NSLog("Something else")
        }
    }
    
    // Returns the number of items that the data source manages for the combo box
    func numberOfItemsInComboBox(aComboBox: NSComboBox!) -> Int
    {
        if menu1Options == nil
        {
            return 0
        }
        
        var retVal: Int = 0
        // anArray is an NSArray variable containing the objects
        
        if aComboBox == btnMenu1
        {
            retVal = menu1Options.count
        }
        else if aComboBox == btnMenu2
        {
            retVal = menu2Options.count
        }
        else if aComboBox == btnMenu3
        {
            retVal = menu3Options.count
        }
        else
        {
            retVal = menu4Options.count
        }
        
        return retVal
    }
    
    // Returns the object that corresponds to the item at the specified index in the combo box
    func comboBox(aComboBox: NSComboBox!, objectValueForItemAtIndex index: Int) -> AnyObject!
    {
        var retVal: String = ""
        // anArray is an NSArray variable containing the objects
        
        if aComboBox == btnMenu1
        {
            retVal = menu1Options[index]
        }
        else if aComboBox == btnMenu2
        {
            retVal = menu2Options[index]
        }
        else if aComboBox == btnMenu3
        {
            retVal = menu3Options[index]
        }
        else
        {
            retVal = menu4Options[index]
        }
        
        return retVal
    }

    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if collectionView == collection1
        {
            retVal = table1Contents.count
        }
        else if collectionView == collection2
        {
            retVal = table2Contents.count
        }
        else if collectionView == collection3
        {
            retVal = table3Contents.count
        }
        else // if collectionView == collection4
        {
            retVal = table4Contents.count
        }
        
        return retVal
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem
    {
        var myCell: MainLabelObject!
        var rows: Int = 0
        
        if collectionView == collection1
        {
            myCell = MainLabelObject(title: table1Contents[indexPath.item].displayText, targetObject: table1Contents[indexPath.item], targetType: btnMenu1.stringValue, sourceView: collectionView, table: "Table1")
            rows = table1Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection2
        {
            myCell = MainLabelObject(title: table2Contents[indexPath.item].displayText, targetObject: table2Contents[indexPath.item], targetType: btnMenu2.stringValue, sourceView: collectionView, table: "Table2")
            rows = table2Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection3
        {
            myCell = MainLabelObject(title: table3Contents[indexPath.item].displayText, targetObject: table3Contents[indexPath.item], targetType: btnMenu3.stringValue, sourceView: collectionView, table: "Table3")
            rows = table3Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else // if collectionView == collection4
        {
            myCell = MainLabelObject(title: table4Contents[indexPath.item].displayText, targetObject: table4Contents[indexPath.item], targetType: btnMenu4.stringValue, sourceView: collectionView, table: "Table4")
            rows = table4Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        
        
        let cellView = collectionView.makeItemWithIdentifier("collectionCellMainScreen", forIndexPath: indexPath)
        
        let mySize = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 17))
        
        if (indexPath.item % 2 == 0)
        {
            myCell.cellColor = myRowColour
        }
        else
        {
            myCell.cellColor = CGColorGetConstantColor(kCGColorClear)
        }
        
        cellView.representedObject = myCell
        
        cellView.preferredContentSize = mySize

        return cellView
    }
     
    func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize
    {
        var retVal: NSSize!
        
        var rows: Int = 0
        
        if collectionView == collection1
        {
            rows = table1Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection2
        {
            rows = table2Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection3
        {
            rows = table3Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else // if collectionView == collection4
        {
            rows = table4Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }

        retVal = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 21))
        
        return retVal
    }
    
    @IBAction func btnMenu1(sender: NSPopUpButton)
    {
    }
    
    @IBAction func btnMenu2(sender: NSPopUpButton)
    {
    }
    
    @IBAction func btnMenu3(sender: NSPopUpButton)
    {
    }
    
    @IBAction func btnMenu4(sender: NSPopUpButton)
    {
    }
    
    @IBAction func buttonAddClicked(sender: NSButton)
    {
        var dataType: String = ""
            
        // First we need to work out the type of data in the table, we get this from the button
            
        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it
            
        switch sender
        {
            case btnAdd1:
                dataType = btnMenu1.stringValue
                reBuildTableName = "Table1"
                
            case btnAdd2:
                dataType = btnMenu2.stringValue
                reBuildTableName = "Table2"
                
            case btnAdd3:
                dataType = btnMenu3.stringValue
                reBuildTableName = "Table3"
                
            case btnAdd4:
                dataType = btnMenu4.stringValue
                reBuildTableName = "Table4"
                
            default:
                print("btnAddClicked: tag hit default for some reason")
                
        }
            
        let selectedType: String = getFirstPartofString(dataType)
            
        switch selectedType
        {
            case "Reminders":
                NSLog("Do add reminder")
                var myFullName: String
                if myDisplayType == "Project"
                {
                    myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                    myFullName = myContextName
                }
                else
                {
                    myFullName = personContact.fullName
                }
                
            //    openReminderAddView(myFullName)
                
            case "Evernote":
                NSLog("Do add Evernote")
                var myFullName: String
                if myDisplayType == "Project"
                {
                    myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                    myFullName = myContextName
                }
                else
                {
                    myFullName = personContact.fullName
                }
                
            //    openEvernoteAddView(myFullName)
                
            case "Omnifocus":
                NSLog("do omnifocus add")
                var myOmniUrlPath: String
                
                if myDisplayType == "Project"
                {
                    myOmniUrlPath = "omnifocus:///add?name=Set Project to '\(mySelectedProject.projectName)'"
                }
                else
                {
                    var myFullName: String = ""
                    if myDisplayType == "Context"
                    {
                        myFullName = myContextName
                    }
                    else
                    {
                        myFullName = personContact.fullName
                    }
                    myOmniUrlPath = "omnifocus:///add?name=Set Context to '\(myFullName)'"
                }
                
                let escapedURL = myOmniUrlPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                let myOmniUrl: NSURL = NSURL(string: escapedURL!)!
                
  //              if UIApplication.sharedApplication().canOpenURL(myOmniUrl) == true
   //             {
    //                UIApplication.sharedApplication().openURL(myOmniUrl)
      //          }
                
            case "Calendar":
                NSLog("Do calendar add")
                
       //         let evc = EKEventEditViewController()
       //         evc.eventStore = eventStore
       //         evc.editViewDelegate = self
       //         self.presentViewController(evc, animated: true, completion: nil)
                
            case "OneNote":
                NSLog("Do Onenote add")
                /*
                var myItemFound: Bool = false
                var myStartPage: String = ""
                
                // First check, if a project does the notebook exist already, or if a person, does the Section in People notebook exist
                
                if myDisplayType == "Project"
                {
                    let alert = UIAlertController(title: "OneNote", message:
                        "Creating OneNote Notebook for this Project.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    self.presentViewController(alert, animated: false, completion: nil)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    
                    
                    myItemFound = myOneNoteNotebooks.checkExistenceOfNotebook(mySelectedProject.projectName)
                    if myItemFound
                    {
                        let alert = UIAlertController(title: "OneNote", message:
                            "Notebook already exists for this Project", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        self.presentViewController(alert, animated: false, completion: nil)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    }
                    else
                    {
                        myStartPage = self.myOneNoteNotebooks.createNewNotebookForProject(self.mySelectedProject.projectName)
                    }
                }
                else
                {
                    var myFullName: String = ""
                    if myDisplayType == "Context"
                    {
                        myFullName = myContextName
                    }
                    else
                    {
                        myFullName = personContact.fullName
                    }
                    
                    if myFullName != ""
                    {
                        let alert = UIAlertController(title: "OneNote", message:
                            "Creating OneNote Section for this Person.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        self.presentViewController(alert, animated: false, completion: nil)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        
                        myItemFound = myOneNoteNotebooks.checkExistenceOfPerson(myFullName)
                        if myItemFound
                        {
                            let alert = UIAlertController(title: "OneNote", message:
                                "Entry already exists for this Person", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            self.presentViewController(alert, animated: false, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        }
                        else
                        {
                            // Create a Section for the Person and add an initial page
                            
                            myStartPage = myOneNoteNotebooks.createNewSectionForPerson(myFullName)
                        }
                    }
                }
                
                let myOneNoteUrlPath = myStartPage
                
                let myOneNoteUrl: NSURL = NSURL(string: myOneNoteUrlPath)!
                
                if UIApplication.sharedApplication().canOpenURL(myOneNoteUrl) == true
                {
                    UIApplication.sharedApplication().openURL(myOneNoteUrl)
                }
*/
            case "Tasks":
                let workingTask = task(inTeamID: myCurrentTeam.teamID)
                
                let tasksViewControl = self.storyboard!.instantiateControllerWithIdentifier("macTaskViewController") as! macTaskViewController
                
                tasksViewControl.passedTask = workingTask
                tasksViewControl.delegate = self
                tasksViewControl.table = reBuildTableName
                
                self.presentViewControllerAsModalWindow(tasksViewControl)
            
            default:
                NSLog("Do nothing")
        }
    }
    
    
    @IBAction func btnSetDate(sender: NSButton)
    {
        myWorkingTask.startDate = datePicker.dateValue

        switch myWorkingTable
        {
            case "Table1":
                table1Contents = Array()
                populateArraysForTables("Table1")
            
            case "Table2":
                table2Contents = Array()
                populateArraysForTables("Table2")
            
            case "Table3":
                table3Contents = Array()
                populateArraysForTables("Table3")
            
            case "Table4":
                table4Contents = Array()
                populateArraysForTables("Table4")
            
            default:print("displayTaskOptions: inTable hit default for some reason")
        }
        
        datePicker.hidden = true
        btnSetDate.hidden = true
        showFields()

    }
    
    func hideFields()
    {
        lblHeader.hidden = true
        btnMenu1.hidden = true
        btnMenu2.hidden = true
        btnMenu3.hidden = true
        btnMenu4.hidden = true
        btnAdd1.hidden = true
        btnAdd2.hidden = true
        btnAdd3.hidden = true
        btnAdd4.hidden = true
        colScroll1.hidden = true
        colScroll2.hidden = true
        colScroll3.hidden = true
        colScroll4.hidden = true
        datePicker.hidden = true
        btnSetDate.hidden = true
    }

    func showFields()
    {
        lblHeader.hidden = false
        btnMenu1.hidden = false
        btnMenu2.hidden = false
        btnMenu3.hidden = false
        btnMenu4.hidden = false
        colScroll1.hidden = false
        colScroll2.hidden = false
        colScroll3.hidden = false
        colScroll4.hidden = false
    }
    
    func buildSidebar()
    {
        headerArray.removeAll()
        
        let planningObject = createMenuItem("Planning", dataItem: "Planning", dataArray: [])
        
        headerArray.append(planningObject)
        
        let inboxObject = createMenuItem("Inbox", dataItem: "Inbox", dataArray: [])
        
        headerArray.append(inboxObject)

        var teamArray: [menuObjectMac] = Array()

        for myTeamItem in myDatabaseConnection.getMyTeams(myID)
        {
            var projectArray: [menuObjectMac] = Array()
            let myTeam = team(inTeamID: myTeamItem.teamID as Int)
            
            let myProjects = myDatabaseConnection.getProjects(myTeam.teamID)
            for myProject in myProjects
            {
                // Get the number of items in the project
                
                let myReturnedData = myDatabaseConnection.getActiveTasksForProject(myProject.projectID as Int)
                
                let myProjectItem = project(inProjectID: myProject.projectID as Int, inTeamID: myProject.teamID as Int)
                let displayObject = createMenuItem("\(myProject.projectName) (\(myReturnedData.count))",  dataItem: myProjectItem)
                
                projectArray.append(displayObject)
            }
            
            let teamObject = createMenuItem(myTeam.name, dataItem: myTeam.name, dataArray: projectArray)

            teamArray.append(teamObject)
        }
        
        let doingObject = createMenuItem("Doing", dataItem: "Doing", dataArray: teamArray)
        
        headerArray.append(doingObject)
        
        let myContextList = contexts()
        // Get list of People Contexts

        var peopleArray: [menuObjectMac] = Array()

        for myContext in myContextList.people
        {
            let myReturnedData = getContextCount(myContext.contextID)
            
            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", dataItem: myContext)
            
            peopleArray.append(displayObject)
        }
        
        let contextMaintenceObject1 = createMenuItem("Maintain People", dataItem: "Maintain People")
        peopleArray.append(contextMaintenceObject1)
        
        let peopleObject = createMenuItem("People", dataItem: "People", dataArray: peopleArray)
        
        headerArray.append(peopleObject)

        // Get list of Non People Contexts
        var placeArray: [menuObjectMac] = Array()

        for myContext in myContextList.places
        {
            let myReturnedData = getContextCount(myContext.contextID)
            
            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", dataItem: myContext)
            
            placeArray.append(displayObject)
        }
        
        let contextMaintenceObject2 = createMenuItem("Maintain Places", dataItem: "Maintain Places")
        
        placeArray.append(contextMaintenceObject2)
        
        let placeObject = createMenuItem("Places", dataItem: "Places", dataArray: placeArray)
        
        headerArray.append(placeObject)

        var toolArray: [menuObjectMac] = Array()

        for myContext in myContextList.tools
        {
            let myReturnedData = getContextCount(myContext.contextID)
            
            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", dataItem: myContext)
            
            toolArray.append(displayObject)
        }
        
        let contextMaintenceObject3 = createMenuItem("Maintain Tools", dataItem: "Maintain Tools")
        
        toolArray.append(contextMaintenceObject3)
        
        let toolObject = createMenuItem("Tools", dataItem: "Tools", dataArray: toolArray)
        
        headerArray.append(toolObject)
       
        var optionArray: [menuObjectMac] = Array()
        
        let displayPanesObject = createMenuItem("Maintain Display Panes", dataItem: "Maintain Display Panes")
        
        optionArray.append(displayPanesObject)
        
        let settingObject = createMenuItem("Settings", dataItem: "Settings")
        
        optionArray.append(settingObject)
        
        let actionsObject = createMenuItem("Options", dataItem: "Options", dataArray: optionArray)
        
        headerArray.append(actionsObject)
    }
    
    func createMenuItem(name: String, dataItem: NSObject, dataArray: [NSObject] = []) -> menuObjectMac
    {
        let myNewObject = menuObjectMac()
        myNewObject.name = name
        myNewObject.array = dataArray
        myNewObject.object = dataItem
        
        return myNewObject
    }

    func getContextCount(contextID: Int) -> Int
    {
        var retVal: Int = 0
        
        // Get list of tasks for the context
        for myItem in myDatabaseConnection.getTasksForContext(contextID)
        {
            // get items that are open
            if myDatabaseConnection.getActiveTask(myItem.taskID as Int).count > 0
            {
                retVal++
            }
        }
        
        return retVal
    }

    func sideBarDidSelect(passedItem:menuObjectMac)
    {
        if passedItem.object.isKindOfClass(project)
        {
            loadProject(passedItem.object as! project)
        }
        else if passedItem.object.isKindOfClass(context)
        {
            loadContext(passedItem.object as! context)
        }
        else if passedItem.object.isKindOfClass(NSString)
        {
            let myText = passedItem.object as! String
            
            if myText == "Planning"
            {
                NSLog("Do Planning viewcontroller")
                
                //                let projectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("GTDPlanning") as! MaintainGTDPlanningViewController
                
                //                let myPassedGTD = GTDModel()
                
                //               myPassedGTD.delegate = self
                //               myPassedGTD.actionSource = "Project"
                
                //                projectViewControl.passedGTD = myPassedGTD
                
                //                self.presentViewController(projectViewControl, animated: true, completion: nil)
            }
            else if myText == "Inbox"
            {
                let inboxViewControl = self.storyboard!.instantiateControllerWithIdentifier("macTaskInbox") as! macTaskInbox
                
                self.presentViewControllerAsModalWindow(inboxViewControl)
            }
            else if myText == "Maintain People" || myText == "Maintain Places" || myText == "Maintain Tools"
            {
                NSLog("Do maintain context viewcontroller")
//                let maintainContextViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("maintainContexts") as! MaintainContextsViewController
                
//                maintainContextViewControl.delegate = self
                
//                self.presentViewController(maintainContextViewControl, animated: true, completion: nil)
            }
            else if myText == "Maintain Display Panes"
            {
                NSLog("Do maintain display panes viewcontroller")
//                let maintainPaneViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainPanes") as! MaintainPanesViewController
                
//                maintainPaneViewControl.delegate = self
                
//                self.presentViewController(maintainPaneViewControl, animated: true, completion: nil)

            }
            else if myText == "Settings"
            {
                NSLog("Do settings view controller")
//                let settingViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("Settings") as! settingsViewController
//                settingViewControl.delegate = self
//                settingViewControl.evernoteSession = evernoteSession
//                settingViewControl.dropboxCoreService = dropboxCoreService
                
//                self.presentViewController(settingViewControl, animated: true, completion: nil)

            }
        }
    }
    
    func loadContext(passedContext: context)
    {
        if passedContext.contextType == "Person"
        {
            let myPerson = findPersonRecord(passedContext.name)
    
            if myPerson == nil
            {
                displayContext(passedContext.name)
            }
            else
            {
                loadPerson(myPerson)
            }
        }
        else
        {
            displayContext(passedContext.name)
        }
    }
  
    func loadProject(passedProject: project)
    {
        showFields()
        
        myDisplayType = "Project"
        mySelectedProject = passedProject
        
        displayScreen()
        
        table1Contents.removeAll(keepCapacity: false)
        table2Contents.removeAll(keepCapacity: false)
        table3Contents.removeAll(keepCapacity: false)
        table4Contents.removeAll(keepCapacity: false)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            self.populateArraysForTables("Table1")
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            self.populateArraysForTables("Table2")
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            self.populateArraysForTables("Table3")
        }
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            self.populateArraysForTables("Table4")
        }
        
        // Here is where we will set the titles for the buttons
        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, title: mySelectedProject.projectName))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, title: mySelectedProject.projectName))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, title: mySelectedProject.projectName))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, title: mySelectedProject.projectName))
        
        collection1.reloadData()
        collection2.reloadData()
        collection3.reloadData()
        collection4.reloadData()
    }
    
    func loadPerson(personRecord: CNContact)
    {
        showFields()
        
        myDisplayType = "Person"
        
        // we need to go and find the record for the person we have selected
        
        personContact = iOSContact(contactRecord: personRecord)
        displayScreen()
        
        table1Contents.removeAll(keepCapacity: false)
        table2Contents.removeAll(keepCapacity: false)
        table3Contents.removeAll(keepCapacity: false)
        table4Contents.removeAll(keepCapacity: false)
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons

        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, title: personContact.fullName))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, title: personContact.fullName))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, title: personContact.fullName))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, title: personContact.fullName))
    }
    
    func displayContext(context: String)
    {
        showFields()
        
        myDisplayType = "Context"
        myContextName = context
        
        // we need to go and find the record for the person we have selected
        
        displayScreen()
        
        table1Contents.removeAll(keepCapacity: false)
        table2Contents.removeAll(keepCapacity: false)
        table3Contents.removeAll(keepCapacity: false)
        table4Contents.removeAll(keepCapacity: false)
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons

        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, title: context))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, title: context))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, title: context))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, title: context))
    }

    func displayScreen()
    {
        // Go and get the list of available panes
        
        let myPanes = displayPanes()
        
        var myButtonName: String = ""
        
        if myDisplayType == "Person"
        {
            myButtonName = personContact.fullName
        }
        else if myDisplayType == "Context"
        {
            myButtonName = myContextName
        }
        else
        {
            myButtonName = mySelectedProject.projectName
        }
        
        lblHeader.stringValue = myButtonName
        
        TableOptions.removeAll()
        
        for myPane in myPanes.listVisiblePanes
        {
            TableOptions.append(myPane.paneName)
            
            if myPane.paneOrder == 1
            {
                setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, title: myButtonName))
                itemSelected = myPane.paneName
            }
            
            if myPane.paneOrder == 2
            {
                setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, title: myButtonName))
            }
            
            if myPane.paneOrder == 3
            {
                setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, title: myButtonName))
            }
            
            if myPane.paneOrder == 4
            {
                setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, title: myButtonName))
            }
        }
    }

    func setButtonTitle(button: NSComboBox, title: String) -> String
    {
        var workString: String = ""
        
        let dataType = button.stringValue
        
        let selectedType: String = getFirstPartofString(dataType)
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
        case "Reminders":
            workString = "Reminders: use List '\(title)'"
            
        case "Evernote":
            workString = "Evernote: use Tag '\(title)'"
            
        case "Omnifocus":
            if myDisplayType == "Project"
            {
                workString = "Omnifocus: use Project '\(title)'"
            }
            else
            {
                workString = "Omnifocus: use Context '\(title)'"
            }
            
        case "OneNote":
            
            if myDisplayType == "Project"
            {
                workString = "OneNote: use Notebook '\(title)'"
            }
            else
            {
                workString = "OneNote: use Notebook 'People' and Section '\(title)'"
            }
            
        default:
            workString = button.stringValue
        }
        
        if myDisplayType != ""
        {
            setAddButton(button)
        }
        
        return workString
    }
    
    func setAddButton(button: NSComboBox)
    {
        let selectedType = getFirstPartofString(button.stringValue)
  
        var btnAdd: NSButton!
        
        if button == btnMenu1
        {
            btnAdd = btnAdd1
        }
        else if button == btnMenu2
        {
            btnAdd = btnAdd2
        }
        else if button == btnMenu3
        {
            btnAdd = btnAdd3
        }
        else //if button == btnMenu4
        {
            btnAdd = btnAdd4
        }
        
        switch selectedType
        {
            case "Reminders":
                btnAdd.hidden = false
            
            case "Evernote":
                button.hidden = false
            
            case "Omnifocus":
                btnAdd.hidden = false
            
            case "Calendar":
                btnAdd.hidden = false
            
            case "OneNote":
                btnAdd.hidden = false
            
            case "Tasks":
                btnAdd.hidden = false
            
            default:
                btnAdd.hidden = true
        }
    }

    func populateArraysForTables(inTable : String)
    {
        
        // work out the table we are populating so we can then use this later
        switch inTable
        {
        case "Table1":
            table1Contents = populateArrayDetails(inTable)
         //   dispatch_async(dispatch_get_main_queue())
         //   {
                self.collection1.reloadData()
        //    }
            
        case "Table2":
            table2Contents = populateArrayDetails(inTable)
        //    dispatch_async(dispatch_get_main_queue())
        //    {
                self.collection2.reloadData()
        //    }
            
        case "Table3":
            table3Contents = populateArrayDetails(inTable)
         //   dispatch_async(dispatch_get_main_queue())
         //   {
                self.collection3.reloadData()
         //   }
            
        case "Table4":
            table4Contents = populateArrayDetails(inTable)
         //   dispatch_async(dispatch_get_main_queue())
         //   {
                self.collection4.reloadData()
         //   }
            
        default:
            print("populateArraysForTables: hit default for some reason")
            
        }
    }
    
    func populateArrayDetails(passedTable: String) -> [TableData]
    {
        var workArray: [TableData] = [TableData]()
        var dataType: String = ""
        
        // First we need to work out the type of data in the table, we get this from the button
        
        switch passedTable
        {
            case "Table1":
                dataType = btnMenu1.stringValue

            case "Table2":
                dataType = btnMenu2.stringValue
            
            case "Table3":
                dataType = btnMenu3.stringValue
            
            case "Table4":
                dataType = btnMenu4.stringValue
            
            default:
                print("populateArrayDetails: inTable hit default for some reason")
            
        }
        
        if myDisplayType == "Project"
        {
            lblHeader.stringValue = mySelectedProject.projectName
        }
        else if myDisplayType == "Context"
        {
            lblHeader.stringValue = myContextName
        }
        else
        {
            lblHeader.stringValue = personContact.fullName
        }
        
        let selectedType: String = getFirstPartofString(dataType)
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
            case "Details":
                if myDisplayType == "Project"
                {
                    workArray = parseProjectDetails(mySelectedProject)
                }
                else if myDisplayType == "Context"
                {
                    writeRowToArray("Context = \(myContextName)", inTable: &workArray)
                }
                else
                {
                    workArray = personContact.tableData
                }
       
            case "Calendar":
                eventDetails = iOSCalendar(inEventStore: eventStore)
            
                if myDisplayType == "Project"
                {
                    eventDetails.loadCalendarDetails(mySelectedProject.projectName)
                }
                else if myDisplayType == "Context"
                {
                    writeRowToArray("No calendar entries found", inTable: &workArray)
                }
                else
                {
                    eventDetails.loadCalendarDetails(personContact.emailAddresses)
                }
                workArray = eventDetails.displayEvent()
            
                if workArray.count == 0
                {
                    writeRowToArray("No calendar entries found", inTable: &workArray)
                }
            
            case "Reminders":
                reminderDetails = iOSReminder()
                var workingName: String = ""
                if myDisplayType == "Project"
                {
                    reminderDetails.parseReminderDetails(mySelectedProject.projectName)
                }
                else
                {
                    if myDisplayType == "Context"
                    {
                        workingName = myContextName
                    }
                    else
                    {
                        workingName = personContact.fullName
                    }
                    reminderDetails.parseReminderDetails(workingName)
                }
                workArray = reminderDetails.displayReminder()
            
            case "Evernote":
                NSLog("Todo Evernote")
                /*
                writeRowToArray("Loading Evernote data.  Pane will refresh when finished", inTable: &workArray)
                if myDisplayType == "Project"
                {
                    myEvernote.findEvernoteNotes(mySelectedProject.projectName)
                }
                else
                {
                    var searchString: String = ""
                    if myDisplayType == "Context"
                    {
                        searchString = myContextName
                    }
                    else
                    {
                        searchString = personContact.fullName
                    }
                    myEvernote.findEvernoteNotes(searchString)
                }
                EvernoteTargetTable = inTable
                */
            
            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    workArray = displayTeamMembers(mySelectedProject, lookupArray: &projectMemberArray)
                }
                else
                {
                    var searchString: String = ""
                    if myDisplayType == "Context"
                    {
                        searchString = myContextName
                    }
                    else
                    {
                        searchString = personContact.fullName
                    }
                    workArray = displayProjectsForPerson(searchString, lookupArray: &projectMemberArray)
                }
            
            /*
            
            case "Omnifocus":
            
                writeRowToArray("Loading Omnifocus data.  Pane will refresh when finished", inTable: &workArray)
            
                omniTableToRefresh = inTable
            
                openOmnifocusDropbox()
                */
            
            case "OneNote":
                NSLog("Todo Evernote")
                /*
                writeRowToArray("Loading OneNote data.  Pane will refresh when finished", inTable: &workArray)
            
                oneNoteTableToRefresh = inTable
            
                if myOneNoteNotebooks == nil
                {
                    myOneNoteNotebooks = oneNoteNotebooks(inViewController: self)
                }
                else
                {
                    OneNoteNotebookGetSections()
                }
                */
            
            case "GMail":
                NSLog("todo Gmail")
                /*
                writeRowToArray("Loading GMail messages.  Pane will refresh when finished", inTable: &workArray)
            
                gmailTableToRefresh = inTable
            
                // Does connection to GmailData exist
            
                if myGmailData == nil
                {
                    myGmailData = gmailData()
                    myGmailData.sourceViewController = self
                    myGmailData.connectToGmail()
                }
                else
                {
                    loadGmail()
                }
                */
            
            case "Hangouts":
                NSLog("Todo hangouts")
                
                /*
                writeRowToArray("Loading Hangout messages.  Pane will refresh when finished", inTable: &workArray)
            
                hangoutsTableToRefresh = inTable
            
                if myGmailData == nil
                {
                    myGmailData = gmailData()
                    myGmailData.sourceViewController = self
                    myGmailData.connectToGmail()
                }
                else
                {
                    loadHangouts()
                }
                */
            
            case "Tasks":
                myTaskItems.removeAll(keepCapacity: false)
            
                var myReturnedData: [Task] = Array()
                if myDisplayType == "Project"
                {
                    myReturnedData = myDatabaseConnection.getActiveTasksForProject(mySelectedProject.projectID)
                }
                else
                {
                    // Get the context name
                    var searchString: String = ""
                    if myDisplayType == "Context"
                    {
                        searchString = myContextName
                    }
                    else
                    {
                        searchString = personContact.fullName
                    }
                
                    let myContext = myDatabaseConnection.getContextByName(searchString)
                
                    if myContext.count != 0
                    {
                        // Context retrieved
                    
                        // Get the tasks based on the retrieved context ID
                    
                        let myTaskContextList = myDatabaseConnection.getTasksForContext(myContext[0].contextID as Int)
                    
                        for myTaskContext in myTaskContextList
                        {
                            // Get the context details
                            let myTaskList = myDatabaseConnection.getActiveTask(myTaskContext.taskID as Int)
                        
                            for myTask in myTaskList
                            {  //append project details to work array
                                myReturnedData.append(myTask)
                            }
                        }
                    }
                }
            
                // Sort workarray by dueDate, with oldest first
                myReturnedData.sortInPlace({$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
            
                // Load calendar items array based on return array
            
                for myItem in myReturnedData
                {
                    let myTempTask = task(taskID: myItem.taskID as Int)
                
                    myTaskItems.append(myTempTask)
                }
            
                workArray = buildTaskDisplay()
            
                if workArray.count == 0
                {
                    writeRowToArray("No tasks found", inTable: &workArray)
                }

            default:
                print("populateArrayDetails: dataType hit default for some reason : \(selectedType)")
        }
        return workArray
    }

    func buildTaskDisplay() -> [TableData]
    {
        var tableContents: [TableData] = [TableData]()
        
        // Build up the details we want to show ing the calendar
        
        for myTask in myTaskItems
        {
            var myString = "\(myTask.title)\n"
            
            myString += "Project: "
            
            let myData = myDatabaseConnection.getProjectDetails(myTask.projectID)
            
            if myData.count == 0
            {
                myString += "No project set"
            }
            else
            {
                myString += myData[0].projectName
            }
            
            myString += "   Due: "
            if myTask.displayDueDate == ""
            {
                myString += "No due date set"
            }
            else
            {
                myString += myTask.displayDueDate
            }
            writeRowToArray(myString, table: &tableContents, targetTask: myTask)
        }
        return tableContents
    }

    func populateMenu() -> [String]
    {
        var workingArray: [String] = Array()
        let myPanes = displayPanes()
        
        for myPane in myPanes.listVisiblePanes
        {
            workingArray.append(myPane.paneName)
        }
        
        return workingArray
    }
    
    func setMenuTitle(button: NSComboBox, dataArray: [String], searchText: String)
    {
        var itemCount: Int = 0
        
        for myString in dataArray
        {
            if myString == searchText
            {
                button.selectItemAtIndex(itemCount)
                break
            }
            itemCount++
        }
    }
    
    func dataCellClicked(notification: NSNotification)
    {
        let mySelectedItemDetails = notification.userInfo!["selectedItemDetails"] as! selectedItemDetails
        let selectedType = mySelectedItemDetails.targetType
        let targetObject = mySelectedItemDetails.targetObject
        let title = mySelectedItemDetails.title
        let sourceView = mySelectedItemDetails.sourceView
        let table = mySelectedItemDetails.table
        
        switch selectedType
        {
        case "Reminders":
            if targetObject.displayText != "No reminders list found"
            {
                /*                  reBuildTableName = table
                
                var myFullName: String
                if myDisplayType == "Project"
                {
                myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                myFullName = myContextName
                }
                else
                {
                myFullName = personContact.fullName
                }
                openReminderEditView(reminderDetails.reminders[rowID].calendarItemIdentifier, inCalendarName: myFullName)
                */
            }
        case "Evernote":
            if targetObject.displayText != "No Notes found"
            {
                /*                    reBuildTableName = table
                
                var myEvernoteDataArray = myEvernote.getEvernoteDataArray()
                
                let myGuid = myEvernoteDataArray[rowID].identifier
                let myNoteRef = myEvernoteDataArray[rowID].NoteRef
                
                openEvernoteEditView(myGuid, inNoteRef: myNoteRef)
                */
            }
            
        case "Calendar":
            NSLog("calendar to do")
            /*
            let calendarOption: UIAlertController = UIAlertController(title: "Calendar Options", message: "Select action to take", preferredStyle: .ActionSheet)
            
            let edit = UIAlertAction(title: "Edit Meeting", style: .Default, handler: { (action: UIAlertAction) -> () in
            // doing something for "product page
            let evc = EKEventEditViewController()
            evc.eventStore = eventStore
            evc.editViewDelegate = self
            evc.event = self.eventDetails.events[rowID]
            self.presentViewController(evc, animated: true, completion: nil)
            })
            
            let agenda = UIAlertAction(title: "Agenda", style: .Default, handler: { (action: UIAlertAction) -> () in
            // doing something for "product page"
            self.openMeetings("Agenda", workingTask: self.eventDetails.calendarItems[rowID])
            })
            
            let minutes = UIAlertAction(title: "Minutes", style: .Default, handler: { (action: UIAlertAction) -> () in
            // doing something for "product page"
            self.openMeetings("Minutes", workingTask: self.eventDetails.calendarItems[rowID])
            })
            
            let personNotes = UIAlertAction(title: "Personal Notes", style: .Default, handler: { (action: UIAlertAction) -> () in
            // doing something for "product page"
            self.openMeetings("Personal Notes", workingTask: self.eventDetails.calendarItems[rowID])
            })
            
            var agendaDisplay: Bool = false
            if eventDetails.calendarItems[myRowClicked].startDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
            { // Start date is in the future
            calendarOption.addAction(edit)
            calendarOption.addAction(agenda)
            agendaDisplay = true
            }
            
            // Is there an Agenda created for the meeting, if not then do not display Minutes or Notes options
            
            var minutesDisplay: Bool = false
            eventDetails.calendarItems[myRowClicked].loadAgenda()
            if eventDetails.calendarItems[myRowClicked].agendaItems.count > 0
            { // Start date is in the future
            calendarOption.addAction(minutes)
            calendarOption.addAction(personNotes)
            minutesDisplay = true
            }
            
            if agendaDisplay || minutesDisplay
            {
            calendarOption.popoverPresentationController?.sourceView = self.view
            calendarOption.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)
            
            self.presentViewController(calendarOption, animated: true, completion: nil)
            }
            calendarTable = table
            */
            
        case "Project Membership":
            NSLog("PM to do")
            // Project team membership details
            /*                if myDisplayType == "Project"
            {
            let myPerson: ABRecord = findPersonRecord(projectMemberArray[rowID]) as ABRecord
            loadPerson(myPerson)
            }
            else
            {
            loadProject(Int(projectMemberArray[rowID])!, teamID: myCurrentTeam.teamID)
            }
            */
            
        case "OneNote":
            NSLog("onenote to do")
            /*                let myOneNoteUrlPath = myOneNoteNotebooks.pages[rowID].urlCallback
            
            //  let myEnUrlPath = stringByChangingChars(myTempPath, " ", "%20")
            let myOneNoteUrl: NSURL = NSURL(string: myOneNoteUrlPath)!
            
            if UIApplication.sharedApplication().canOpenURL(myOneNoteUrl) == true
            {
            UIApplication.sharedApplication().openURL(myOneNoteUrl)
            }
            */
            
        case "GMail":
            NSLog("GMail to do")
            /*                hideFields()
            
            myWebView.hidden = false
            btnSendToInbox.hidden = false
            btnCloseWindow.hidden = false
            myWorkingGmailMessage = myGmailMessages.messages[rowID]
            myWebView.loadHTMLString(myGmailMessages.messages[rowID].body, baseURL: nil)
            */
            
        case "Hangouts":
            NSLog("hangouts to do")
            /*                showFields()
            
            myWebView.hidden = false
            btnSendToInbox.hidden = false
            
            btnCloseWindow.hidden = false
            myWorkingGmailMessage = myHangoutsMessages.messages[rowID]
            myWebView.loadHTMLString(myHangoutsMessages.messages[rowID].body, baseURL: nil)
            */
            
        case "Tasks":
            let popover = NSPopover()
            
            let myViewController = self.storyboard?.instantiateControllerWithIdentifier("popupMenuViewController") as? popupMenuViewController
            myViewController!.header = "Select action to take"
            myViewController!.menuArray = displayTaskOptions(targetObject.targetTask)
            myViewController!.workingObject = targetObject.targetTask
            myViewController!.table = table
            myViewController!.delegate = self
            myViewController!.controller = popover
            
            
            popover.contentViewController = myViewController
            
            popover.behavior = NSPopoverBehavior.Transient
            
            popover.showRelativeToRect(sourceView.bounds, ofView: sourceView, preferredEdge: NSRectEdge.MinY)
            
        default:
            NSLog("Do nothing")
        }
        
    }

    func displayTaskOptions(workingTask: task) -> [popupMenuOptions]
    {
        var myOptions: [popupMenuOptions] = Array()
        
        let myOption1 = popupMenuOptions()
        myOption1.itemDescription = "Edit Action"
        myOption1.itemAction = "Task: Edit Action"
        
        myOptions.append(myOption1)

        let myOption3 = popupMenuOptions()
        myOption3.itemDescription = "Defer: 1 Hour"
        myOption3.itemAction = "Task: Defer: 1 Hour"
        
        myOptions.append(myOption3)

        let myOption4 = popupMenuOptions()
        myOption4.itemDescription = "Defer: 4 Hour"
        myOption4.itemAction = "Task: Defer: 4 Hour"
        
        myOptions.append(myOption4)

        let myOption5 = popupMenuOptions()
        myOption5.itemDescription = "Defer: 1 Day"
        myOption5.itemAction = "Task: Defer: 1 Day"
        
        myOptions.append(myOption5)

        let myOption6 = popupMenuOptions()
        myOption6.itemDescription = "Defer: 1 Week"
        myOption6.itemAction = "Task: Defer: 1 Week"
        
        myOptions.append(myOption6)

        let myOption7 = popupMenuOptions()
        myOption7.itemDescription = "Defer: 1 Month"
        myOption7.itemAction = "Task: Defer: 1 Month"
        
        myOptions.append(myOption7)

        let myOption8 = popupMenuOptions()
        myOption8.itemDescription = "Defer: 1 Year"
        myOption8.itemAction = "Task: Defer: 1 Year"
        
        myOptions.append(myOption8)

        let myOption9 = popupMenuOptions()
        myOption9.itemDescription = "Defer: Custom"
        myOption9.itemAction = "Task: Defer: Custom"
        
        myOptions.append(myOption9)

        return myOptions
    }
    
    func myTaskDidFinish(table: String)
    {
        switch table
        {
            case "Table1":
                self.table1Contents = Array()
                self.populateArraysForTables("Table1")
            
            case "Table2":
                self.table2Contents = Array()
                self.populateArraysForTables("Table2")
            
            case "Table3":
                self.table3Contents = Array()
                self.populateArraysForTables("Table3")
            
            case "Table4":
                self.table4Contents = Array()
                self.populateArraysForTables("Table4")
            
            default:
                print("myTaskDidFinish: table hit default for some reason")
        }
    }
    
    func myPopupDidSelect(row: Int, table: String, action: String, workingObject: AnyObject)
    {
        switch action
        {
            case "Task: Edit Action" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                    let tasksViewControl = self.storyboard!.instantiateControllerWithIdentifier("macTaskViewController") as! macTaskViewController
            
                    tasksViewControl.passedTask = workingTask
                    tasksViewControl.delegate = self
                    tasksViewControl.table = table
            
                    self.presentViewControllerAsModalWindow(tasksViewControl)
                }
            
            case "Task: Defer: 1 Hour" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                    
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Hour,
                        value: 1,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: 4 Hour" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                    
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Hour,
                        value: 4,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: 1 Day" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Day,
                        value: 1,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: 1 Week" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Day,
                        value: 7,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: 1 Month" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                    
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Month,
                        value: 1,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: 1 Year" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
                
                    let myCalendar = NSCalendar.currentCalendar()
                
                    let newTime = myCalendar.dateByAddingUnit(
                        .Year,
                        value: 1,
                        toDate: NSDate(),
                        options: [])!
                
                    workingTask.startDate = newTime
                }
            
            case "Task: Defer: Custom" :
                if workingObject.isKindOfClass(task)
                {
                    let workingTask = workingObject as! task
            
                    if workingTask.displayStartDate == ""
                    {
                        datePicker.dateValue = NSDate()
                    }
                    else
                    {
                        datePicker.dateValue = workingTask.startDate
                    }
                
                    datePicker.datePickerMode = NSDatePickerMode.SingleDateMode
                    datePicker.datePickerStyle = NSDatePickerStyle.ClockAndCalendarDatePickerStyle
                    
                    hideFields()
                
                    datePicker.hidden = false
                    btnSetDate.hidden = false
                    myWorkingTask = workingTask
                    myWorkingTable = table
                }

            default:
                print("myPopupDidSelect: action hit default for some reason")
            
        }

        switch table
        {
            case "Table1":
                self.table1Contents = Array()
                self.populateArraysForTables("Table1")
            
            case "Table2":
                self.table2Contents = Array()
                self.populateArraysForTables("Table2")
            
            case "Table3":
                self.table3Contents = Array()
                self.populateArraysForTables("Table3")
            
            case "Table4":
                self.table4Contents = Array()
                self.populateArraysForTables("Table4")
            
            default:
                print("myPopupDidSelect: table hit default for some reason")
        }
    }
    

}

class mainCollectionCell: NSObject
{
    var label: NSString!
}

class selectedItemDetails: NSObject
{
    var title:String = ""
    var targetObject: TableData!
    var targetType: String = ""
    var sourceView: NSView!
    var table: String = ""
}


class MainLabelCollectionViewItemView: NSView {
    
    // MARK: properties
    
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
    
    // MARK: NSView
    
    override var wantsUpdateLayer: Bool
    {
        return true
    }
    
    override func updateLayer()
    {
//        if selected
//        {
//            self.layer?.cornerRadius = 10
//            layer!.backgroundColor = NSColor.whiteColor().CGColor
//        } 
//        else
//        {
//            self.layer?.cornerRadius = 0
//            layer!.backgroundColor = NSColor.whiteColor().CGColor
//        }
//        layer!.backgroundColor = NSColor.whiteColor().CGColor
//        layer!.backgroundColor = NSColor.redColor().CGColor
    }
    
    // MARK: init
    
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

class MainLabelObject: NSObject
{
    var title:String
    var targetObject: TableData
    var targetType: String
    var sourceView: NSView
    var table: String
    var cellColor: CGColor!
    
    init(title:String, targetObject: TableData, targetType: String, sourceView: NSView, table: String)
    {
        self.title = title
        self.targetObject = targetObject
        self.targetType = targetType
        self.sourceView = sourceView
        self.table = table
    }
    
    func dataCellClicked()
    {
        let selectedType: String = getFirstPartofString(targetType)
        
        let myItem = selectedItemDetails()
        myItem.targetType = selectedType
        myItem.title = title
        myItem.targetObject = targetObject
        myItem.sourceView = sourceView
        myItem.table = table
        
        let selectedDictionary = ["selectedItemDetails" : myItem]
        
        NSNotificationCenter.defaultCenter().postNotificationName("NSDataCellClickedNotification", object: nil, userInfo:selectedDictionary)
    }
}


class MainLabelCollectionViewItem: NSCollectionViewItem
{
    var labelObject: MainLabelObject?
    {
        return representedObject as? MainLabelObject
    }
    
    override var selected: Bool
    {
        didSet
        {
            (self.view as! MainLabelCollectionViewItemView).selected = selected
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState
    {
        didSet
        {
            (self.view as! MainLabelCollectionViewItemView).highlightState = highlightState
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
            
            labelObject?.dataCellClicked()
        }
    }
    
    override func viewWillAppear()
    {
        let rows = labelObject!.title.componentsSeparatedByString("\n").count

        name.setFrameSize(NSSize(width: collectionView.frame.width, height: CGFloat(rows * 17)))
        
        (self.view as! MainLabelCollectionViewItemView).layer!.backgroundColor = labelObject!.cellColor
        (self.view as! MainLabelCollectionViewItemView).setFrameSize(NSSize(width: collectionView.frame.width, height: CGFloat(rows * 21)))
        
        
    }
}

