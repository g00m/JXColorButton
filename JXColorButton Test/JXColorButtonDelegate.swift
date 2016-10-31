//
//  JXColorButtonDelegate.swift
//  JXColorButton Test
//
//  Created by Joseph Essin on 4/17/16.
//

import Cocoa

@objc protocol JXColorButtonDelegate {
  func colorSelected(_ sender: JXColorButton, color: NSColor)
}
