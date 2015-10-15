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

class macStartViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSCollectionViewDelegate
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
        
        let minSize = NSMakeSize(0,0)
        
        collection1.maxItemSize = minSize
        collection2.maxItemSize = minSize
        collection3.maxItemSize = minSize
        collection4.maxItemSize = minSize
        
        
        
        
        // Do any additional setup after loading the view.
        hideFields()
        
        buildSidebar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "outlineViewChanged:", name:"NSOutlineViewSelectionDidChangeNotification", object: nil)

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
            myCell = MainLabelObject(title: table1Contents[indexPath.item].displayText, targetObject: table1Contents[indexPath.item], targetType: btnMenu1.stringValue)
            rows = table1Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection2
        {
            myCell = MainLabelObject(title: table2Contents[indexPath.item].displayText, targetObject: table2Contents[indexPath.item], targetType: btnMenu2.stringValue)
            rows = table2Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else if collectionView == collection3
        {
            myCell = MainLabelObject(title: table3Contents[indexPath.item].displayText, targetObject: table3Contents[indexPath.item], targetType: btnMenu3.stringValue)
            rows = table3Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        else // if collectionView == collection4
        {
            myCell = MainLabelObject(title: table4Contents[indexPath.item].displayText, targetObject: table4Contents[indexPath.item], targetType: btnMenu4.stringValue)
            rows = table4Contents[indexPath.item].displayText.componentsSeparatedByString("\n").count
        }
        
        
        let cellView = collectionView.makeItemWithIdentifier("collectionCellMainScreen", forIndexPath: indexPath)
        
        let mySize = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 17))
        
//        cellView.frame
        
        
        cellView.representedObject = myCell

        /*
        if (indexPath.item % 2 == 0)
        {
            cellView.backgroundColor = myRowColour
        }
        else
        {
            cellView.txtCell!.backgroundColor = NSColor.whiteColor()
        }
*/
        
        cellView.preferredContentSize = mySize

        return cellView
    }
    
    
    func collectionView(collectionView : NSCollectionView,layout collectionViewLayout:NSCollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> NSSize
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

        retVal = NSSize(width: collectionView.frame.width, height: CGFloat(rows * 17))
        
        return retVal
    }

    
    
    
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>)
    {
        var table: String = ""
        
        if collectionView == collection1
        {
            table = "Table1"
        }
        else if collectionView == collection2
        {
            table = "Table2"
        }
        else if collectionView == collection3
        {
            table = "Table3"
        }
        else // if collectionView == collection4
        {
            table = "Table4"
        }

        if let selectedIndexPath = collectionView.selectionIndexPaths.first
            where selectedIndexPath.section != -1 && selectedIndexPath.item != -1
        {
                // There is a selected index path, get the image at that path.
            
                dataCellClicked(selectedIndexPath.item, table: table, viewClicked: collectionView)
        }
        
        
        
       // handleSelectionChanged()
        
       // dataCellClicked(rowID: Int, table: String, viewClicked: NSView)
    }
    
    
    /*
    func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>)
    {
        handleSelectionChanged()
    }
    
    private func handleSelectionChanged() {
        guard let imageSelectionHandler = imageSelectionHandler else { return }
        
        /*
        The collection view does not support multiple selection, so just check
        the first index.
        */
        let selectedImage: ImageFile?
        
        if let selectedIndexPath = collectionView.selectionIndexPaths.first
            where selectedIndexPath.section != -1 && selectedIndexPath.item != -1 {
                // There is a selected index path, get the image at that path.
                selectedImage = imageCollections[selectedIndexPath.section].images[selectedIndexPath.item]
        }
        else {
            /*
            There is no selected index path -- the collection view supports
            empty selection, there is no selected image.
            */
            selectedImage = nil
        }
        
        imageSelectionHandler(selectedImage)
    }

 */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
/*
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        var rows: Int = 0
        
        if tableView == table1
        {
            rows = table1Contents[row].displayText.componentsSeparatedByString("\n").count
        }
        else if tableView == table2
        {
            rows = table2Contents[row].displayText.componentsSeparatedByString("\n").count
        }
        else if tableView == table3
        {
            rows = table3Contents[row].displayText.componentsSeparatedByString("\n").count
        }
        else // if aTableView == table4
        {
            rows = table4Contents[row].displayText.componentsSeparatedByString("\n").count
        }
        
        return CGFloat(rows * 17)
    }
*/

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
    
    @IBAction func btnAdd1(sender: NSButton)
    {
    }
    
    @IBAction func btnAdd2(sender: NSButton)
    {
    }
    
    @IBAction func btnAdd3(sender: NSButton)
    {
    }
    
    @IBAction func btnAdd4(sender: NSButton)
    {
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
        collection1.hidden = true
        collection2.hidden = true
        collection3.hidden = true
        collection4.hidden = true
    }

    func showFields()
    {
        lblHeader.hidden = false
        btnMenu1.hidden = false
        btnMenu2.hidden = false
        btnMenu3.hidden = false
        btnMenu4.hidden = false
        collection1.hidden = false
        collection2.hidden = false
        collection3.hidden = false
        collection4.hidden = false
        
        NSLog("Need to add code for showing the correct add buttons")
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
                NSLog("Do Inbox viewcontroller")
                //                let GTDInboxViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("GTDInbox") as! GTDInboxViewController
                
                //                GTDInboxViewControl.delegate = self
                
                //                self.presentViewController(GTDInboxViewControl, animated: true, completion: nil)
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
        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, inTitle: mySelectedProject.projectName))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, inTitle: mySelectedProject.projectName))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, inTitle: mySelectedProject.projectName))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, inTitle: mySelectedProject.projectName))
        
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

        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, inTitle: personContact.fullName))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, inTitle: personContact.fullName))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, inTitle: personContact.fullName))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, inTitle: personContact.fullName))
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

        setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, inTitle: context))
        setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, inTitle: context))
        setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, inTitle: context))
        setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, inTitle: context))
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
                setMenuTitle(btnMenu1, dataArray: menu1Options, searchText: setButtonTitle(btnMenu1, inTitle: myButtonName))
                itemSelected = myPane.paneName
            }
            
            if myPane.paneOrder == 2
            {
                setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu2, dataArray: menu2Options, searchText: setButtonTitle(btnMenu2, inTitle: myButtonName))
            }
            
            if myPane.paneOrder == 3
            {
                setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu3, dataArray: menu3Options, searchText: setButtonTitle(btnMenu3, inTitle: myButtonName))
            }
            
            if myPane.paneOrder == 4
            {
                setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: myPane.paneName)
                setMenuTitle(btnMenu4, dataArray: menu4Options, searchText: setButtonTitle(btnMenu4, inTitle: myButtonName))
            }
        }
    }

    func setButtonTitle(inButton: NSComboBox, inTitle: String) -> String
    {
        var workString: String = ""
        
        let dataType = inButton.stringValue
        
        let selectedType: String = getFirstPartofString(dataType)
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
        case "Reminders":
            workString = "Reminders: use List '\(inTitle)'"
            
        case "Evernote":
            workString = "Evernote: use Tag '\(inTitle)'"
            
        case "Omnifocus":
            if myDisplayType == "Project"
            {
                workString = "Omnifocus: use Project '\(inTitle)'"
            }
            else
            {
                workString = "Omnifocus: use Context '\(inTitle)'"
            }
            
        case "OneNote":
            
            if myDisplayType == "Project"
            {
                workString = "OneNote: use Notebook '\(inTitle)'"
            }
            else
            {
                workString = "OneNote: use Notebook 'People' and Section '\(inTitle)'"
            }
            
        default:
            workString = inButton.stringValue
        }
        
        if myDisplayType != ""
        {
            setAddButtonState(inButton.tag)
        }
        
        return workString
    }
    
    func setAddButtonState(inTable: Int)
    {
        // Hide all of the buttons
        // Decide which buttons to show
        
        var selectedType: String = ""
        
        switch inTable
        {
        case 1:
            selectedType = getFirstPartofString(btnMenu1.stringValue)
            
            switch selectedType
            {
            case "Reminders":
                
                btnAdd1.hidden = false
                
            case "Evernote":
                btnAdd1.hidden = false
                
            case "Omnifocus":
                btnAdd1.hidden = false
                
            case "Calendar":
                btnAdd1.hidden = false
                
            case "OneNote":
                btnAdd1.hidden = false
                
            default:
                btnAdd1.hidden = true
            }
            
        case 2:
            selectedType = getFirstPartofString(btnMenu2.stringValue)
            
            switch selectedType
            {
            case "Reminders":
                btnAdd2.hidden = false
                
            case "Evernote":
                btnAdd2.hidden = false
                
            case "Omnifocus":
                btnAdd2.hidden = false
                
            case "Calendar":
                btnAdd2.hidden = false
                
            case "OneNote":
                btnAdd2.hidden = false
                
            default:
                btnAdd2.hidden = true
            }
            
        case 3:
            selectedType = getFirstPartofString(btnMenu3.stringValue)
            
            switch selectedType
            {
            case "Reminders":
                btnAdd3.hidden = false
                
            case "Evernote":
                btnAdd3.hidden = false
                
            case "Omnifocus":
                btnAdd3.hidden = false
                
            case "Calendar":
                btnAdd3.hidden = false
                
            case "OneNote":
                btnAdd3.hidden = false
                
            default:
                btnAdd3.hidden = true
            }
            
        case 4:
            selectedType = getFirstPartofString(btnMenu4.stringValue)
            
            switch selectedType
            {
            case "Reminders":
                btnAdd4.hidden = false
                
            case "Evernote":
                btnAdd4.hidden = false
                
            case "Omnifocus":
                btnAdd4.hidden = false
                
            case "Calendar":
                btnAdd4.hidden = false
                
                
            case "OneNote":
                btnAdd4.hidden = false
                
            default:
                btnAdd4.hidden = true
            }
            
        default: break
        }
    }

    func populateArraysForTables(inTable : String)
    {
        
        // work out the table we are populating so we can then use this later
        switch inTable
        {
        case "Table1":
            table1Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.collection1.reloadData()
            }
            
        case "Table2":
            table2Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.collection2.reloadData()
            }
            
        case "Table3":
            table3Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.collection3.reloadData()
            }
            
        case "Table4":
            table4Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.collection4.reloadData()
            }
            
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
            writeRowToArray(myString, inTable: &tableContents)
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
    
    func dataCellClicked(rowID: Int, table: String, viewClicked: NSView)
    {
        var dataType: String = ""
        // First we need to work out the type of data in the table, we get this from the button
        
        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it
        
        var myRowContents: String = "'"
        let myRowClicked = rowID
        
        switch table
        {
            case "Table1":
                dataType = btnMenu1.stringValue
                myRowContents = table1Contents[rowID].displayText
            
            case "Table2":
                dataType = btnMenu2.stringValue
                myRowContents = table2Contents[rowID].displayText
            
            case "Table3":
                dataType = btnMenu3.stringValue
                myRowContents = table3Contents[rowID].displayText
            
            case "Table4":
                dataType = btnMenu4.stringValue
                myRowContents = table4Contents[rowID].displayText
            
            default:
                print("dataCellClicked: inTable hit default for some reason")
            
        }
        
        let selectedType: String = getFirstPartofString(dataType)
        
        switch selectedType
        {
            case "Reminders":
                if myRowContents != "No reminders list found"
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
                if myRowContents != "No Notes found"
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
                
                let mypopup = popupMenuView()
            
                
                
                //let myOptions = displayTaskOptions(myTaskItems[rowID], targetTable: table)
                //myOptions.popoverPresentationController!.sourceView = viewClicked
            
           //     self.presentViewController(myOptions, animated: true, completion: nil)
            
            default:
                NSLog("Do nothing")
        }
    }
/*
    func displayTaskOptions(workingTask: task, targetTable: String) -> NSMenu
    {
        let myOptions: NSMenuItem = NSMenuItem(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit Action", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(0,0,700,700)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(0,0,700,700)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Defer: 1 Hour", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Hour,
                value: 1,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption4 = UIAlertAction(title: "Defer: 4 Hours", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Hour,
                value: 4,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                
            default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption5 = UIAlertAction(title: "Defer: 1 Day", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Day,
                value: 1,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                
            default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption6 = UIAlertAction(title: "Defer: 1 Week", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Day,
                value: 7,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                
            default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption7 = UIAlertAction(title: "Defer: 1 Month", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Month,
                value: 1,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                
            default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption8 = UIAlertAction(title: "Defer: 1 Year", style: .Default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = NSCalendar.currentCalendar()
            
            let newTime = myCalendar.dateByAddingUnit(
                .Year,
                value: 1,
                toDate: NSDate(),
                options: [])!
            
            workingTask.startDate = newTime
            
            switch targetTable
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
                
            default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption9 = UIAlertAction(title: "Defer: Custom", style: .Default, handler: { (action: UIAlertAction) -> () in
            if workingTask.displayStartDate == ""
            {
                self.myDatePicker.date = NSDate()
            }
            else
            {
                self.myDatePicker.date = workingTask.startDate
            }
            
            self.myDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.hideFields()
            self.myDatePicker.hidden = false
            self.btnSetStartDate.hidden = false
            self.myWorkingTask = workingTask
            self.myWorkingTable = targetTable
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        myOptions.addAction(myOption5)
        myOptions.addAction(myOption6)
        myOptions.addAction(myOption7)
        myOptions.addAction(myOption8)
        myOptions.addAction(myOption9)
        
        return myOptions
    }

*/
}

class mainCollectionCell: NSObject
{
    var label: NSString!
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
        layer!.backgroundColor = NSColor.whiteColor().CGColor
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
    
    init(title:String, targetObject: TableData, targetType: String)
    {
        self.title = title
        self.targetObject = targetObject
        self.targetType = targetType
    }
    
    func dataCellClicked()
    {
         NSLog(" click \(title)")
        
        // First we need to work out the type of data in the table, we get this from the button
        
        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it
        
        let selectedType: String = getFirstPartofString(targetType)
        
        
        NSLog("Selected type = \(selectedType)")
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
            
                let mypopup = popupMenuView()
            
        
            
            
            //let myOptions = displayTaskOptions(myTaskItems[rowID], targetTable: table)
            //myOptions.popoverPresentationController!.sourceView = viewClicked
            
            //     self.presentViewController(myOptions, animated: true, completion: nil)
            
            default:
                NSLog("Do nothing")
        }

    }
}


class MainLabelCollectionViewItem: NSCollectionViewItem
{
    // MARK: properties
    
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
    
    // MARK: outlets
    
    @IBOutlet weak var name: NSTextField!
    
    // MARK: NSResponder
    
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
//        NSLog("frame = \(name.frame.width), \(name.frame.height)")
        
        
        name.setFrameSize(NSSize(width: collectionView.frame.width, height: CGFloat(rows * 17)))
        
  //      NSLog("frame \(labelObject!.title) = \(name.frame.width), \(name.frame.height)")
        
     //   name.sizeToFit()
    }
}

