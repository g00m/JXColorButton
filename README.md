# JXColorButton
JXColorButton is a custom color well for OS X to provide additional functionality to NSColorWell. It provides a button filled with the selected color. When clicked, it opens a popover menu that displays the provided array of colors, allowing the user to easily select one. This control is similar to the color selector provided in TextEdit in the text view inspector bar. JXColorButton also plays nicely with the OS X color picker for custom colors.

<img src="https://raw.githubusercontent.com/josephessin/JXColorButton/master/demo.gif" align="right" width="50" />

## Getting Setup
To use a JXColorButton, simply drop a custom view in and set its class to JXColorButton and implement the JXColorButton delegate on your view controller or window controller. You can customize most of the settings for the JXColorButton via interface builder or via code.

Note: JXColorButton may or may not render properly in XCode, depending on build settings. Despite this, you can still drag from the custom view to create a reference to it. Once you have a reference, you can customize it via code. Investigation is underway to fix this.

Here's a quick sample of how your code might look if you're using a window controller. A view controller also works similarly.

The example project demonstrates how easy it is to setup a button, customize its appearance, and handle the message it receives:

```swift
import Cocoa
class WindowController: NSWindowController, JXColorButtonDelegate {
    
    @IBOutlet weak var colorPicker1: JXColorButton!
    @IBOutlet weak var colorPicker2: JXColorButton!

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
```
## What you can customize
JXColorButton provides a lot of options to customize. Here's the full spec:

* defaultBackgroundColor
   This is a static property that represents the button's default background color if you don't specify one.

You can customize the colors, dark/light background vibrancy of the popover, menu text, coloring, spacing, selection highlight colors, custom image/icon, and a host of other options. Many of these customizations are demonstrated in the sample project provided. The code is well documented, tested on OS X 10.11 (although it needs more testing), and written in Swift 2.


