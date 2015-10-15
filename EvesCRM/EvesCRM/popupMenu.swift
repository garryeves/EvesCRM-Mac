//
//  popupMenu.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//
// Based on
//
//  LibraryToolbarView.swift
//  DocHub
//
//  Created by Tristan Juricek on 6/14/14.
//  Copyright (c) 2014 Perforce. All rights reserved.
//

import AppKit
import Foundation


class popupMenuView : NSView
{
    
    let borderColor = NSColor(SRGBRed: 0.69, green: 0.71875, blue: 0.7421, alpha: 1.0)
    let backgroundColor = NSColor(SRGBRed: 0.95, green: 0.94, blue: 0.95, alpha: 1.0)
    
    let libraryAddButton:NSPopUpButton
    let libraryAddCell:NSPopUpButtonCell
    
    override init(frame:NSRect)
    {
        let libraryAddRect = NSRect(x: 1, y: 10, width: 42, height: 18)
        libraryAddButton = NSPopUpButton(frame: libraryAddRect, pullsDown: true)
        libraryAddCell = libraryAddButton.cell as! NSPopUpButtonCell
        
        super.init(frame: frame)
        
        libraryAddCell.bezeled = false
        libraryAddCell.bordered = false
        
        libraryAddCell.addItemWithTitle("")
        libraryAddCell.addItemWithTitle("Add Perforce Account")
        libraryAddCell.addItemWithTitle("Add GitHub Account")
        
        let firstItem = libraryAddCell.itemAtIndex(0)
     //   firstItem!.image = NSImage(named: "icon-add-library.png")
    //    firstItem!.image!.scalesWhenResized()
        firstItem!.onStateImage = nil
        firstItem!.mixedStateImage = nil
        
        addSubview(libraryAddButton)
        libraryAddButton.synchronizeTitleAndSelectedItem()
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        backgroundColor.set()
        NSRectFill(NSRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.frame.height - 1)
        )
        
        borderColor.setStroke()
        let defW = NSBezierPath.defaultLineWidth()
        NSBezierPath.setDefaultLineWidth(1)
        NSBezierPath.strokeLineFromPoint(
            NSPoint(x: 0, y: self.frame.height),
            toPoint: NSPoint(x: self.frame.width, y: self.frame.height))
        NSBezierPath.setDefaultLineWidth(defW)
        
        super.drawRect(dirtyRect)
    }
}
