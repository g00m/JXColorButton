//
//  AppDelegate.swift
//  JEColorButton
//
//  Created by Joseph Essin on 4/15/16.
//  Copyright © 2016 Joseph Essin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Has to be an instance variable or it gets garbage collected
    // and no window is ever able to be shown...
    let myWindowController = WindowController(windowNibName: "Window")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        myWindowController.showWindow(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}

