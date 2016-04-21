//
//  NSImageView Tinted Extension.swift
//  Wink
//
//  Created by Joseph Essin on 4/1/16.
//

import Cocoa

extension NSImage {
    /**
     Returns a version of the image tinted to the specified color.
     Thanks, internet!
     https://lists.apple.com/archives/cocoa-dev/2009/Aug/msg01872.html
     - Parameter withColor: The color to tint the image.
     - Returns: The new, tinted image.
     */
    func tintedImage(withColor: NSColor) -> NSImage {
        let size = self.size
        let imageBounds = NSMakeRect(0, 0, size.width, size.height)
        let copiedImage = self.copy() as! NSImage
        copiedImage.lockFocus()
        withColor.set()
        NSRectFillUsingOperation(imageBounds, NSCompositingOperation.CompositeSourceAtop)
        copiedImage.unlockFocus()
        return copiedImage
    }
}