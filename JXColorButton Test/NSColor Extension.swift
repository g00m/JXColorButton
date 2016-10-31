//
//  NSColor Extension.swift
//  JXColorButton
//
//

import Cocoa

extension NSColor {
  
  /// Compares a color with itself and returns true if they are equal.
  func isEqualToColor(_ otherColor : NSColor) -> Bool {
    
    // Credit of:
    // http://stackoverflow.com/a/30646646/4615448
    // Slight modifications were made by Joseph E. to be NSColor compatible instead
    // of for UIColor.
    
    //if self == otherColor {
    //    return true
    //}
    
    let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
    let convertColorToRGBSpace : ((_ color : NSColor) -> NSColor?) = { (color) -> NSColor? in
      if color.cgColor.colorSpace?.model == CGColorSpaceModel.monochrome {
        let oldComponents = color.cgColor.components
        let components : [CGFloat] = [ oldComponents![0], oldComponents![0], oldComponents![0], oldComponents![1] ]
        let colorRef = CGColor(colorSpace: colorSpaceRGB, components: components)
        let colorOut = NSColor(cgColor: colorRef!)
        return colorOut
      }
      else {
        return color;
      }
    }
    
    let selfColor = convertColorToRGBSpace(self)
    let otherColor = convertColorToRGBSpace(otherColor)
    
    if let selfColor = selfColor, let otherColor = otherColor {
      return selfColor.isEqual(otherColor)
    }
    else {
      return false
    }
  }
}

func ==(left: NSColor, right: NSColor) -> Bool {
  if left.isEqualToColor(right) { return true }
  return false
}
