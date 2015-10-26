//
//  popupMenuViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 21/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Cocoa

protocol MyPopupDelegate
{
    func myPopupDidSelect(row: Int, table: String, action: String, workingObject: AnyObject)
}

class popupMenuViewController: NSViewController
{
    var delegate: MyPopupDelegate?
    var controller: NSPopover!
    
    @IBOutlet weak var lblHeader: NSTextField!
    @IBOutlet weak var tableMenu: NSTableView!
    
    var header: String = ""
    var menuArray: [popupMenuOptions]!
    var table: String = ""
    var workingObject: AnyObject!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do view setup here.
        
        lblHeader.stringValue = header
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        return menuArray.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier("popupMenuItem", owner: self) as! NSTableCellView
        
        cellView.textField!.stringValue = menuArray[row].itemDescription

        return cellView
    }
    
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return CGFloat(50)
    }
    
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if let currentTableView = notification.object as? NSTableView
        {
            delegate?.myPopupDidSelect(currentTableView.selectedRow, table: table, action: menuArray[currentTableView.selectedRow].itemAction, workingObject: workingObject)
            controller.close()
        }
    }
    
}

class popupMenuOptions: NSObject
{
    var itemDescription: String = ""
    var itemAction: String = ""
}
