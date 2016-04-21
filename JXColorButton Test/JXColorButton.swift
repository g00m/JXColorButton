//
//  JEColorButton.swift
//  JEColorButton
//
//  Created by Joseph Essin on 4/15/16.
//  Copyright © 2016 Joseph Essin. All rights reserved.
//

import Cocoa

/// An NSButton subclass that allows the user to pick a color from a list
/// of colors in a popover. This button is highly configurable.
@objc @IBDesignable class JXColorButton: NSView, JXColorGridViewDelegate {
    
    // MARK: Static Properties
    
    /// The default background color of the button.
    static var defaultBackgroundColor: NSColor = NSColor.whiteColor()
    
    /// A list of default colors to supply to the color button.
    static var defaultColorList: [[NSColor]] = [
        [NSColor.whiteColor(),  NSColor.grayColor(),    NSColor.darkGrayColor(), NSColor.blackColor(), ],
        [NSColor.redColor(),    NSColor.magentaColor(), NSColor.purpleColor(),   NSColor.orangeColor() ],
        [NSColor.yellowColor(), NSColor.blueColor(),    NSColor.cyanColor(),     NSColor.greenColor(), ]
    ]
    
    /// The most recently clicked-on JXColorButton.
    static var lastColorButton: JXColorButton?
    
    // MARK: Properties
    
    /// The controller that handles this controls' actions (such as click event).
    /// You can hook this up in interface builder if you like.
    @IBOutlet weak var delegate: JXColorButtonDelegate?
    
    /// The border radius of the button.
    @IBInspectable var borderRadius: CGFloat = 4.0 { didSet(value) { layer?.cornerRadius = value } }
    /// The border color of the button.
    @IBInspectable var borderColor: CGColor = NSColor.lightGrayColor().CGColor { didSet(value) { layer?.borderColor = value } }
    /// The border width of the button.
    @IBInspectable var borderWidth: CGFloat = 1.0 { didSet(value) { layer?.borderWidth = value } }
    
    /// True if the button allows the user to pick a custom color.
    @IBInspectable var usesCustomColor: Bool = true { didSet(value) { configure() } }
    /// True if the user is allowed to pick a default color.
    @IBInspectable var usesDefaultColor: Bool = true { didSet(value) { configure() } }
    /// True if the user is allowed to pick the transparency/alpha value of a custom color.
    /// Only applies if usesCustomColors = true.
    @IBInspectable var usesAlphaChannel: Bool = false { didSet(value) { colorPanel.showsAlpha = value } }
    
    /// The title of the default color menu option, if usesDefaultColor is true.
    @IBInspectable var defaultColorTitle: NSString = "Default Color" { didSet(value) { refreshPopover() } }
    /// The title of the custom color menu option, if usesCustomColor is true.
    @IBInspectable var customColorTitle: NSString = "Custom Color" { didSet(value) { refreshPopover() } }
    
    /// The default color the user is allowed to choose.
    @IBInspectable var defaultColor: NSColor = NSColor.blackColor() { didSet(value) { refreshPopover() } }
    /// The custom color that the user picks.
    @IBInspectable var customColor: NSColor = NSColor.magentaColor() { didSet(value) { refreshPopover() } }
    /// The background color of the button.
    /// If you need to set this back to the default, use
    /// colorButton.backgroundColor = JEColorButton.defaultBackgroundColor
    @IBInspectable var color: NSColor = JXColorButton.defaultBackgroundColor {
        willSet(value) {
            layer?.backgroundColor = value.CGColor
            layer?.setNeedsDisplay()
            if !colorReferenced(value) {
                customColor = colorPanel.color
            }
            // Call the delegate
            if let receiver = delegate {
                receiver.colorSelected(self, color: value)
            }
        }
    }
    
    /// The background color of the popover, if any.
    @IBInspectable var popoverBackgroundColor: NSColor?
    
    /// The horizontal spacing between colors in the grid.
    @IBInspectable var horizontalBoxSpacing: CGFloat = 4.0 { didSet(value) { configure() } }
    /// The vertical spacing between colors in the grid.
    @IBInspectable var verticalBoxSpacing: CGFloat = 4.0 { didSet(value) { configure() } }
    /// The width of the color boxes, in points:
    @IBInspectable var boxWidth: CGFloat = 20.0 { didSet(value) { configure() } }
    /// The height of the color boxes, in points:
    @IBInspectable var boxHeight: CGFloat = 20.0 { didSet(value) { configure() } }
    /// The color of the currently selected color box (defaults to the user's selection color).
    @IBInspectable var selectedBoxColor: NSColor = NSColor.selectedMenuItemColor() { didSet(value) { refreshPopover() } }
    /// The border/stroke width of the color boxes
    @IBInspectable var boxBorderWidth: CGFloat = 1.0 { didSet(value) { refreshPopover() } }
    /// The border/stroke width of the of the selected color box:
    @IBInspectable var selectedBoxBorderWidth: CGFloat = 4.0 { didSet(value) { refreshPopover() } }
    /// The border color of the color boxes
    @IBInspectable var boxBorderColor: NSColor = NSColor.lightGrayColor() { didSet(value) { refreshPopover() } }
    /// The selection color of menu items
    @IBInspectable var selectedMenuItemColor: NSColor = NSColor.selectedMenuItemColor() { didSet(value) { refreshPopover() } }
    /// The color of selected text in a menu item
    @IBInspectable var selectedMenuItemTextColor: NSColor = NSColor.selectedMenuItemTextColor() { didSet(value) { refreshPopover() } }
    // The color of normal text in the menu items:
    @IBInspectable var textColor: NSColor = NSColor.textColor() { didSet(value) { refreshPopover() } }
    /// Whether or not the popover is displayed in dark mode.
    @IBInspectable var darkMode: Bool = false { didSet(value) { configure() } }
    
    /// A two-dimensional array of colors to show in the pop-over view.
    /// Think of it as colors[row][column].
    /// JEColorButton assumes that this is NOT a jagged array, so be sure that all your
    /// sub-arrays are the same length.
    var colors: [[NSColor]] = defaultColorList { didSet { configure() } }
    
    /// The most recent form of color selection.
    var lastSelectionType: JXColorGridViewSelectionType = .ColorGridSelection
    
    /// The number of rows of colors.
    var rows: Int { get { return colors.count  } }
    /// The number of columns of colors.
    var columns: Int { get { return colors[0].count } }
    
    /// The image that the button draws inside the rectangle, if any.
    var image: NSImage?
    
    /// Whether or not the image is rendered as a template color specified by imageColor.
    var imageIsTemplate: Bool = true
    /// The color of the image
    var imageColor: NSColor = NSColor.controlShadowColor()
    /// Vertical padding of the image in points
    var imageVerticalPadding: CGFloat = 2.0
    /// Horizontal padding of the image in points
    var imageHorizontalPadding: CGFloat = 2.0
    
    /// The popover that the button shows.
    private var popover: NSPopover = NSPopover()
    
    /// The popover view controller
    private var popoverViewController: NSViewController = NSViewController()
    
    /// A handle to the color picker.
    private let colorPanel = NSColorPanel.sharedColorPanel()
    
    /// The height of the menu item at the top and bottom of the popover for the default color
    /// and custom color, respectively. This is calculated based on the vertical box spacing
    /// and the heigh tof the color boxes.
    var menuHeight: CGFloat { get { return ((2.0 * verticalBoxSpacing) + boxHeight) } }
    
    // MARK: Initializers
    // These intializers configure the button as soon as its created.
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        configure()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
        configure()
    }
    
    // MARK: Internal
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if let pic = image {
            layer!.sublayers = nil
            let deviceScale = NSScreen.mainScreen()!.backingScaleFactor
            let sublayer = CALayer()
            
            let rawWidth = pic.size.width
            let rawHeight = pic.size.height
            let containerWidth = bounds.size.width - (imageHorizontalPadding * 2.0)
            let containerHeight = bounds.size.height - (imageVerticalPadding * 2.0)
            
            let imgScale = min(containerWidth / rawWidth, containerHeight / rawHeight)
            let newWidth = rawWidth * imgScale
            let newHeight = rawHeight * imgScale
            
            sublayer.bounds = CGRectMake(0, 0, newWidth, newHeight)
            sublayer.contents = pic.layerContentsForContentsScale(deviceScale)
            sublayer.contentsGravity = kCAGravityResizeAspectFill
            sublayer.position = NSMakePoint(self.bounds.size.width / 2, self.bounds.size.height / 2)
            layer!.addSublayer(sublayer)
        }
    }
    
    // MARK: Public Methods
    
    /// Shows the OS X color picker.
    func showColorPanel() {
        colorPanel.showsAlpha = usesAlphaChannel
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(self.colorFromPanel(_:)))
        colorPanel.continuous = true
        NSApplication.sharedApplication().orderFrontColorPanel(self)
    }
    
    /// Call this function when the button is clicked.
    func showColorPopover() {
        // Set our popover to be the right size:
        popover.contentSize = popoverRequiredFrameSize()
        popover.behavior = .Transient
        popover.animates = true
        // Show the popover:
        refreshPopover()
        popover.showRelativeToRect(self.bounds, ofView: self, preferredEdge: .MinY)
    }
    
    // MARK: JXColorGridViewDelegate
    
    func colorWasSelected(sender: JXColorGridView, color: NSColor?, selectionType: JXColorGridViewSelectionType) {
        popover.close()
        lastSelectionType = selectionType
        if color != nil {
            self.color = color!
            colorPanel.color = color!
        } else {
            showColorPanel()
        }
    }
    
    // MARK: Private Methods
    
    /// Tells the popover to redraw.
    private func refreshPopover() {
        popoverViewController.view.needsToDrawRect(popoverViewController.view.bounds)
        popoverViewController.view.display()
    }
    
    /// When the list of colors change, we have to create a new view with the right size
    /// to accomodate for this change.
    private func resetPopoverView() {
        popover.contentViewController!.view =
            JXColorGridView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: popoverRequiredFrameSize()),
                            belongsTo: self)
    }
    
    private func setup() {
        // Configure the button's layer
        wantsLayer = true
        layer = CALayer()
        layer!.delegate = self
        // Configure the border properties:
        layer!.cornerRadius = borderRadius
        layer!.borderColor = borderColor
        layer!.borderWidth = borderWidth
        // Configure the background:
        layer!.backgroundColor = color.CGColor
        
        // Configure our popover:
        popover.contentViewController = popoverViewController
    }
    
    
    /// Configures the button--only needs to be called once.
    private func configure() {
        if darkMode {
            popover.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        } else {
            popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        }
        resetPopoverView()
    }
    
    /// Calculates the size a popover will need to be to properly
    /// display all the colors properly.
    private func popoverRequiredFrameSize() -> NSSize {
        var verticalSpace =
            (verticalBoxSpacing + (CGFloat(rows) * (boxHeight + verticalBoxSpacing)))
        if usesCustomColor { verticalSpace += menuHeight }
        if usesDefaultColor { verticalSpace += menuHeight }
        let horizontalSpace =
            (horizontalBoxSpacing + (CGFloat(columns) * (boxWidth + horizontalBoxSpacing)))
        return NSMakeSize(horizontalSpace, verticalSpace)
    }
    
    /// Returns true if the specified color is listed in the color list.
    private func colorReferenced(color: NSColor) -> Bool {
        if color.isEqualToColor(defaultColor) || color.isEqualToColor(customColor) {
            return true
        }
        for list in colors {
            for colorItem in list {
                if color.isEqualToColor(colorItem) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: Color Panel
    
    @objc private func colorFromPanel(sender: AnyObject?) {
        // Look at the last JXColorButton to have focus and alter it accordingly.
        if let lastColorButton = JXColorButton.lastColorButton {
            lastColorButton.color = colorPanel.color
            lastColorButton.refreshPopover()
            if !lastColorButton.colorReferenced(colorPanel.color) {
                lastColorButton.customColor = colorPanel.color
            }
        }
    }
    
    // MARK: Event Management
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
        showColorPopover()
        JXColorButton.lastColorButton = self
    }
}
