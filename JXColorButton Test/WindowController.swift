//
//  WindowController.swift
//  JEColorButton
//
//  Created by Joseph Essin on 4/15/16.
//  Copyright © 2016 Joseph Essin. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var colorPicker1: JXColorButton!
    @IBOutlet weak var colorPicker2: JXColorButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        colorPicker2.colors = [
            [ NSColor.whiteColor(), NSColor("FF0000"), NSColor("FF00FF"), NSColor("800000"), NSColor("C0504D"), NSColor("D16349"), NSColor("DD8484") ],
            [ NSColor("CCCCCC"),    NSColor("FFC000"), NSColor("C0C0C0"), NSColor("808080"), NSColor("F79646"), NSColor("D19049"), NSColor("F3A447") ],
            [ NSColor("A5A5A5"),    NSColor("FFFF00"), NSColor("00FFFF"), NSColor("808000"), NSColor("9BBB59"), NSColor("CCB400"), NSColor("DFCE04") ],
            [ NSColor("666666"),    NSColor("00FF00"), NSColor("00B050"), NSColor("008000"), NSColor("4BACC6"), NSColor("8FB08C"), NSColor("A5B592") ],
            [ NSColor("333333"),    NSColor("0000FF"), NSColor("004DBB"), NSColor("000080"), NSColor("4F81BD"), NSColor("646B86"), NSColor("809EC2") ],
            [ NSColor.blackColor(), NSColor("9B00D3"), NSColor("008080"), NSColor("800080"), NSColor("8064A2"), NSColor("9E7C7C"), NSColor("9C85C0") ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 0
        colorPicker1.boxBorderColor = NSColor.blackColor()
        colorPicker1.selectedBoxColor = NSColor.whiteColor()
        //colorPicker1.popoverBackgroundColor = NSColor.greenColor()
        colorPicker1.darkMode = true
        colorPicker1.selectedMenuItemColor = NSColor.whiteColor()
        colorPicker1.selectedMenuItemTextColor = NSColor.blackColor()
    }
}

extension NSColor {
    /// Initializes a new NSColor from a hexadecimal string.
    /// https://gist.github.com/arshad/de147c42d7b3063ef7bc
    /// - Parameter hexString: The hexadecimal string.
    /// - Returns: The new color.
    convenience init(_ hexString: String) {
        var cString: String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        if (cString.characters.count != 6) {
            self.init(white: 0.5, alpha: 1.0)
        } else {
            let rString: String = (cString as NSString).substringToIndex(2)
            let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
            let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
            var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            self.init(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: CGFloat(1))
        }
    }
}
