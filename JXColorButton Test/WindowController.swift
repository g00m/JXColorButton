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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Always needs to be a regular a x b array. Jagged arrays don't work.
        colorPicker2.colors = [
            [ NSColor.whiteColor(), NSColor.blackColor(), NSColor.redColor(), NSColor.darkGrayColor() ],
            [ NSColor.greenColor(), NSColor.purpleColor(), NSColor.orangeColor(), NSColor.lightGrayColor() ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 0
        colorPicker1.boxBorderColor = NSColor.blackColor()
        colorPicker1.selectedBoxColor = NSColor.whiteColor()
        //colorPicker1.popoverBackgroundColor = NSColor.greenColor()
        colorPicker1.darkMode = true
        colorPicker1.selectedMenuItemColor = NSColor.whiteColor()
        colorPicker1.selectedMenuItemTextColor = NSColor.blackColor()
        
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
