# JXColorButton
JXColorButton is a custom color well for OS X to provide additional functionality to NSColorWell. It provides a button filled with the selected color. When clicked, it opens a popover menu that displays the provided array of colors, allowing the user to easily select one. This control is similar to the color selector provided in TextEdit in the text view inspector bar. JXColorButton also plays nicely with the OS X color picker for custom colors.

Looking for a textured-rounded NSComboBox? Check out [JXTexturedComboBox](https://github.com/josephessin/JXTexturedComboBox).

<img src="https://raw.githubusercontent.com/josephessin/JXColorButton/master/demo.gif" align="right" width="350" />

## Getting Setup
To use a JXColorButton, simply drop a custom view in, set its class to JXColorButton, and implement the JXColorButton delegate on your view controller or window controller. You can customize most of the settings for the JXColorButton via interface builder or in your code.

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
        
        // Row x Column array representing the colors the user can select from our color popover in the JXColorButton.
        colorPicker2.colors = [
            [ NSColor.whiteColor(), NSColor.blackColor(), NSColor.redColor(), NSColor.darkGrayColor() ],
            [ NSColor.greenColor(), NSColor.purpleColor(), NSColor.orangeColor(), NSColor.lightGrayColor() ]
        ]
        
        colorPicker1.boxWidth = 30
        colorPicker1.borderRadius = 1
        colorPicker1.boxBorderColor = NSColor.blackColor()
        colorPicker1.selectedBoxColor = NSColor.whiteColor()
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

## Development Information
JXColorButton has been utilized in an application of my design, but has not been fully tested in other scenarios. If you encounter bugs and have changes, feel free to make a pull request or file an issue here on GitHub. 

## What you can customize
JXColorButton provides a lot of options to customize, but picks intelligent default values if you don't specify (although you do have to at least set the delegate if you want to know the selected color as it changes). Here's the full spec:

* **defaultBackgroundColor** 

   This is a static NSColor property that represents the button's default background color if you don't specify one.
* **lastColorButton** 

   This is a static JXColorButton property that specifies the last selected color button. Change this to alter which JXColorButton will receive system color panel notifications.
* **delegate** 

   This is the object that implements the colorSelected(sender: JXColorButton, color: NSColor) function to receive the selected color whenever the user makes a selection.
* **borderRadius** 

   A CGFloat representing the button's border radius.
* **borderColor** 

   An NSColor representing the button's border color.
* **borderWidth** 

   The width of the button's border.
* **usesCustomColor** 

   Whether or not the menu has a "Custom Color" option displayed at the bottom of the color selection popover.
* **usesDefaultColor** 

   Whether or not the menu has a "Default Color" option displayed at the top of the color selection popover.
* **usesAlphaChannel** 

   Whether or not the color popover allows the color panel to pick a transparent color.
*  **defaultColorTitle** 

    A String representing the title of the default color menu item, if usesDefaultColor is true.
*  **customColorTitle** 

   A String representing the title of the custom color menu item, if usesCustomColor is true.
* **defaultColor** 

   An NSColor representing the color of the "Default Color" menu item, if usesDefaultColor is true.
* **customColor** 

   An NSColor representing the color of the "Custom Color" menu item, if usesCustomColor is true.
* **color** 

   An NSColor representing the currently selected color.
* **popoverBackgroundColor** 

   An NSColor representing the popover's background color. Possible to change, but not recommended per the Apple Human Interface Guidelines.
* **horizontalBoxSpacing** 

   A CGFloat representing the horizontal distance between color boxes as rendered in the color selection popover.
* **verticalBoxSpacing** 

   A CGFloat representing the vertical distance between color boxes as rendered in the color selection popover.
* **boxWidth** 

   A CGFloat representing the width of each color box as rendered in the color selection popover.
* **boxHeight** 

   A CGFloat representing the height of each color box as rendered in the color selection popover.
* **selectedBoxColor** 

   A CGFloat representing the color of the selected box's border in the color selection popover. Defaults to the system selection color.
* **boxBorderWidth** 

   A CGFloat representing the border width of the color boxes in the color selection popover.
* **selectedBoxBorderWidth** 

   An NSColor representing the border width of the selected color box in the color selection popover.
* **boxBorderColor** 

   An NSColor representing the color of the color box border in the color selection popover.
* **selectedMenuItemColor** 

   An NSColor representing the menu item selection color in the color selection popover. Defaults to the system selection color.
* **selectedMenuItemTextColor** 

   An NSColor representing the color of selected menu item text in the color selection popover. Defaults to the system text selection color.
* **textColor** 

   An NSColor representing the color of the menu item text in the color selection popover.
* **darkMode**

   Whether or not the popover appears as a dark popover or not.
* **image** 

   An NSImage representing the icon for the button to display.
* **imageIsTemplate** 

   Whether or not the image is supposed to be rendered as a template image or not.
* **imageLightColor** 

   The NSColor to render the image, if any, when it is on a light background. Only applies to template images.
* **imageNormalColor** 

   The color to render the image, if any, when it is on a dark background. Only applies to template images.
* **imageVerticalPadding** 

   A CGFloat representing the minimal distance between the image and the top and bottom sides of the JXColor Button.
* **imageHorizontalPadding** 

   A CGFloat representing the minimal distance between the image and the left and right sides of the JXColorButton.
* **colors** 

   A 2D array of NSColors specifying the colors the users can select in the color selection popover. These should not include the default color or custom color, if specified.
* **horizontalMargin** 

  A CGFloat representing the left and right margin distance between the grid of colors and the popover window.
* **verticalMargin** 

  A CGFloat representing the top and bottom margin distance between the grid of colors and the popover window.

## About
This project was created by [Joseph Essin](https://twitter.com/thestardrop).

## License
JXColorButton is provided under the MIT License.

> The MIT License (MIT)
>
> Copyright (c) 2016 Joseph Essin
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
