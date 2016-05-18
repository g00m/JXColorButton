//
//  WindowController.swift
//  JEColorButton
//
//  Created by Joseph Essin on 4/15/16.
//  Copyright © 2016 Joseph Essin. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, JXColorButtonDelegate {
    
    @IBOutlet weak var colorPicker1: JXColorButton!
    @IBOutlet weak var colorPicker2: JXColorButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Row x Column array representing the colors the user can select from our color popover in the JXColorButton.
        colorPicker2.colors = [
            [ NSColor.whiteColor(), NSColor.blackColor(), NSColor.redColor(), NSColor.darkGrayColor() ],
            [ NSColor.greenColor(), NSColor.purpleColor(), NSColor.orangeColor(), NSColor.lightGrayColor() ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 1
        colorPicker1.boxBorderColor = NSColor.blackColor()
        colorPicker1.selectedBoxColor = NSColor.whiteColor()
        colorPicker1.darkMode = true
        colorPicker1.selectedMenuItemColor = NSColor.whiteColor()
        colorPicker1.selectedMenuItemTextColor = NSColor.blackColor()
        
        colorPicker2.color = NSColor.redColor()
        colorPicker2.image = NSImage(named: NSImageNameColorPanel)
        // Set this to true if you're using a template image.
        //colorPicker2.imageIsTemplate = true
        
        // Set the delegates
        colorPicker1.delegate = self
        colorPicker2.delegate = self
    }
    
    /// Sent from our JXColorButtons
    func colorSelected(sender: JXColorButton, color: NSColor) {
        if sender === colorPicker1 {
            Swift.print("Color from picker 1: " + String(color))
        } else if sender === colorPicker2 {
            Swift.print("Color from picker 2: " + String(color))
        }
    }
}