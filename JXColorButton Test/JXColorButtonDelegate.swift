//
//  JXColorButtonDelegate.swift
//  JXColorButton Test
//
//  Created by Joseph Essin on 4/17/16.
//  Copyright © 2016 Joseph Essin. All rights reserved.
//

import Cocoa

@objc protocol JXColorButtonDelegate {
    func colorSelected(sender: JXColorButton, color: NSColor)
}
