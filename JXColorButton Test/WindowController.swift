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
            [ NSColor.white, NSColor.black, NSColor.red, NSColor.darkGray ],
            [ NSColor.green, NSColor.purple, NSColor.orange, NSColor.lightGray ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 1
        colorPicker1.boxBorderColor = NSColor.black
        colorPicker1.selectedBoxColor = NSColor.white
        colorPicker1.darkMode = true
        colorPicker1.selectedMenuItemColor = NSColor.white
        colorPicker1.selectedMenuItemTextColor = NSColor.black
        
        colorPicker2.color = NSColor.red
        colorPicker2.image = NSImage(named: NSImageNameColorPanel)
        // Set this to true if you're using a template image.
        //colorPicker2.imageIsTemplate = true
        
        // Set the delegates
        colorPicker1.delegate = self
        colorPicker2.delegate = self
    }
    
    /// Sent from our JXColorButtons
    func colorSelected(_ sender: JXColorButton, color: NSColor) {
        if sender === colorPicker1 {
            Swift.print("Color from picker 1: " + String(describing: color))
        } else if sender === colorPicker2 {
            Swift.print("Color from picker 2: " + String(describing: color))
        }
    }
}
