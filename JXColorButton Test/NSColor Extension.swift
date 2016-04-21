//
//  NSColor Extension.swift
//  JEColorButton
//
//

import Cocoa

extension NSColor {

    /// Compares a color with itself and returns true if they are equal.
    func isEqualToColor(otherColor : NSColor) -> Bool {
        
        // Credit of:
        // http://stackoverflow.com/a/30646646/4615448
        // Slight modifications were made by Joseph E. to be NSColor compatible instead
        // of for UIColor.
        
        if self == otherColor {
            return true
        }
        
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let convertColorToRGBSpace : ((color : NSColor) -> NSColor?) = { (color) -> NSColor? in
            if CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == CGColorSpaceModel.Monochrome {
                let oldComponents = CGColorGetComponents(color.CGColor)
                let components : [CGFloat] = [ oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1] ]
                let colorRef = CGColorCreate(colorSpaceRGB, components)
                let colorOut = NSColor(CGColor: colorRef!)
                return colorOut
            }
            else {
                return color;
            }
        }
        
        let selfColor = convertColorToRGBSpace(color: self)
        let otherColor = convertColorToRGBSpace(color: otherColor)
        
        if let selfColor = selfColor, otherColor = otherColor {
            return selfColor.isEqual(otherColor)
        }
        else {
            return false
        }
    }
}