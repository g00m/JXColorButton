//
//  JXColorButton.swift
//  JXColorButton
//
//  Created by Joseph Essin on 4/15/16.
//
// JXColorButton

import Cocoa

/// An NSButton subclass that allows the user to pick a color from a list
/// of colors in a popover. This button is highly configurable.
@objc @IBDesignable open class JXColorButton: NSView, JXColorGridViewDelegate, NSAccessibilityButton, CALayerDelegate {
  
  // MARK: Static Properties
  
  /// The default background color of the button.
  static var defaultBackgroundColor: NSColor = NSColor.white
  
  /// A list of default colors to supply to the color button.
  static var defaultColorList: [[NSColor]] = [
    [NSColor.white,  NSColor.gray,    NSColor.darkGray, NSColor.black, ],
    [NSColor.red,    NSColor.magenta, NSColor.purple,   NSColor.orange ],
    [NSColor.yellow, NSColor.blue,    NSColor.cyan,     NSColor.green, ]
  ]
  
  /// The most recently clicked-on JXColorButton.
  /// This is necessary for color panel integration.
  static var lastColorButton: JXColorButton?
  
  // MARK: Properties
  
  /// The button's accessibility label.
  @IBOutlet var label: String? = "Color Picker"
  
  /// The controller that handles this controls' actions (such as click event).
  /// You can hook this up in interface builder if you like.
  @IBOutlet weak var delegate: JXColorButtonDelegate?
  
  /// The border radius of the button.
  @IBInspectable var borderRadius: CGFloat = 4.0 { didSet(value) { layer?.cornerRadius = value } }
  /// The border color of the button.
  @IBInspectable var borderColor: CGColor = NSColor.lightGray.cgColor { didSet(value) { layer?.borderColor = value } }
  /// The border width of the button.
  @IBInspectable var borderWidth: CGFloat = 0.5 { didSet(value) { layer?.borderWidth = value } }
  
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
  @IBInspectable var defaultColor: NSColor = NSColor.black { didSet(value) { refreshPopover() } }
  /// The custom color that the user picks.
  @IBInspectable var customColor: NSColor = NSColor.magenta { didSet(value) { refreshPopover() } }
  /// The background color of the button.
  /// If you need to set this back to the default, use
  /// colorButton.backgroundColor b= JEColorButton.defaultBackgroundColor
  @IBInspectable var color: NSColor = JXColorButton.defaultBackgroundColor {
    willSet(value) {
      layer?.backgroundColor = value.cgColor
      if !colorReferenced(value) {
        customColor = colorPanel.color
      }
      updateImage()
      layer?.setNeedsDisplay()
    }
    didSet(value) {
      updateImage()
    }
  }
  
  /// The background color of the popover, if any.
  @IBInspectable var popoverBackgroundColor: NSColor? { didSet(value) { refreshPopover() } }
  /// The left and right margin distance between the grid of colors and the popover window.
  @IBInspectable var horizontalMargin: CGFloat = 4.0 { didSet(value) { configure() } }
  /// The top and bottom margin distance between the grid of colors and the popover window.
  @IBInspectable var verticalMargin: CGFloat = 4.0 { didSet(value) { configure() } }
  /// The horizontal spacing between colors in the grid.
  @IBInspectable var horizontalBoxSpacing: CGFloat = 4.0 { didSet(value) { configure() } }
  /// The vertical spacing between colors in the grid.
  @IBInspectable var verticalBoxSpacing: CGFloat = 4.0 { didSet(value) { configure() } }
  /// The width of the color boxes, in points:
  @IBInspectable var boxWidth: CGFloat = 20.0 { didSet(value) { configure() } }
  /// The height of the color boxes, in points:
  @IBInspectable var boxHeight: CGFloat = 20.0 { didSet(value) { configure() } }
  /// The color of the currently selected color box (defaults to the user's selection color).
  @IBInspectable var selectedBoxColor: NSColor = NSColor.selectedMenuItemColor { didSet(value) { refreshPopover() } }
  /// The border/stroke width of the color boxes
  @IBInspectable var boxBorderWidth: CGFloat = 1.0 { didSet(value) { refreshPopover() } }
  /// The border/stroke width of the of the selected color box:
  @IBInspectable var selectedBoxBorderWidth: CGFloat = 4.0 { didSet(value) { refreshPopover() } }
  /// The border color of the color boxes
  @IBInspectable var boxBorderColor: NSColor = NSColor.lightGray { didSet(value) { refreshPopover() } }
  /// The selection color of menu items
  @IBInspectable var selectedMenuItemColor: NSColor = NSColor.selectedMenuItemColor { didSet(value) { refreshPopover() } }
  /// The color of selected text in a menu item
  @IBInspectable var selectedMenuItemTextColor: NSColor = NSColor.selectedMenuItemTextColor { didSet(value) { refreshPopover() } }
  // The color of normal text in the menu items:
  @IBInspectable var textColor: NSColor = NSColor.textColor { didSet(value) { refreshPopover() } }
  /// Whether or not the popover is displayed in dark mode.
  @IBInspectable var darkMode: Bool = false { didSet(value) { configure() } }
  
  /// The image that the button draws inside the rectangle, if any.
  @IBInspectable var image: NSImage? {
    set(value) {
      icon = value
      updateImage()
    }
    get {
      return icon
    }
  }
  
  /// Whether or not the image is rendered as a template color specified by imageColor.
  @IBInspectable var imageIsTemplate: Bool = false { didSet(value) { updateImage() } }
  /// The color of the image when it is on a dark background
  @IBInspectable var imageLightColor: NSColor = NSColor.white { didSet(value) { updateImage() } }
  /// The color of hte image when it is on a light or transparent background
  @IBInspectable var imageNormalColor: NSColor = NSColor.controlDarkShadowColor { didSet(value) { updateImage() } }
  /// Vertical padding of the image in points
  @IBInspectable var imageVerticalPadding: CGFloat = 2.0 { didSet(value) { layer?.setNeedsDisplay() } }
  /// Horizontal padding of the image in points
  @IBInspectable var imageHorizontalPadding: CGFloat = 2.0 { didSet(value) { layer?.setNeedsDisplay() } }
  
  /// A two-dimensional array of colors to show in the pop-over view.
  /// Think of it as colors[row][column].
  /// JEColorButton assumes that this is NOT a jagged array, so be sure that all your
  /// sub-arrays are the same length.
  var colors: [[NSColor]] = defaultColorList { didSet { configure() } }
  
  /// The most recent form of color selection.
  var lastSelectionType: JXColorGridViewSelectionType = .colorGridSelection
  
  /// The number of rows of colors.
  var rows: Int { get { return colors.count  } }
  /// The number of columns of colors.
  var columns: Int { get { return colors[0].count } }
  
  /// The popover that the button shows.
  fileprivate var popover: NSPopover = NSPopover()
  
  /// The popover view controller
  fileprivate var popoverViewController: NSViewController = NSViewController()
  
  /// A handle to the color picker.
  fileprivate let colorPanel = NSColorPanel.shared()
  
  /// The image to render--use image property for public access.
  fileprivate var icon: NSImage?
  
  /// The height of the menu item at the top and bottom of the popover for the default color
  /// and custom color, respectively. This is calculated based on the vertical box spacing
  /// and the heigh tof the color boxes.
  var menuHeight: CGFloat { get { return ((2.0 * verticalMargin) + boxHeight) } }
  
  /// This button has the potential to be the first responder to
  /// handle the changeColor event.
  override open var acceptsFirstResponder: Bool {
    get { return true }
  }
  
  // MARK: Initializers
  // These intializers configure the button as soon as its created.
  
  required public init?(coder: NSCoder) {
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
  
  override open func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // If there's an image/icon specified, let's draw it with respect to the padding from the border
    // and its aspect ratio using an image sublayer.
    // This was far more complicated than I had anticipated.
    if let pic = image {
      layer!.sublayers = nil
      let deviceScale = self.window!.backingScaleFactor
      let sublayer = CALayer()
      
      let rawWidth = pic.size.width
      let rawHeight = pic.size.height
      let containerWidth = bounds.size.width - (imageHorizontalPadding * 2.0)
      let containerHeight = bounds.size.height - (imageVerticalPadding * 2.0)
      
      let imgScale = min(containerWidth / rawWidth, containerHeight / rawHeight)
      let newWidth = rawWidth * imgScale
      let newHeight = rawHeight * imgScale
      
      sublayer.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
      sublayer.contents = pic.layerContents(forContentsScale: deviceScale)
      sublayer.contentsGravity = kCAGravityResizeAspectFill
      sublayer.position = NSMakePoint(self.bounds.size.width / 2, self.bounds.size.height / 2)
      layer!.addSublayer(sublayer)
    }
  }
  
  // MARK: Public Methods
  
  /// Shows the OS X color picker.
  func showColorPanel() {
    colorPanel.showsAlpha = usesAlphaChannel
    configureColorPanel()
    colorPanel.isContinuous = true
    NSApplication.shared().orderFrontColorPanel(self)
  }
  
  /// Configures the color panel to respond to this color button
  fileprivate func configureColorPanel() {
    colorPanel.setTarget(self)
    colorPanel.setAction(#selector(self.colorFromPanel(_:)))
  }
  
  /// Call this function when the button is clicked.
  func showColorPopover() {
    if popover.isShown { return }
    // Set our popover to be the right size:
    popover.contentSize = popoverRequiredFrameSize()
    popover.behavior = .transient
    popover.animates = true
    // Show the popover:
    refreshPopover()
    popover.show(relativeTo: self.bounds, of: self, preferredEdge: .minY)
  }
  
  // MARK: JXColorGridViewDelegate
  
  func colorWasSelected(_ sender: JXColorGridView, color: NSColor?, selectionType: JXColorGridViewSelectionType) {
    popover.close()
    var color = color
    lastSelectionType = selectionType
    if selectionType == .customColorPanelDesired {
      if !colorPanel.isVisible {
        showColorPanel()
        color = nil
      }
    }
    if color != nil {
      self.color = color!
      colorPanel.setTarget(nil)
      colorPanel.color = color!
    }
    updateImage()
    if color != nil { delegate?.colorSelected(self, color: color!) }
    colorPanel.setTarget(self)
    colorPanel.setAction(#selector(colorFromPanel(_:)))
  }
  
  // MARK: Private Methods
  
  /// Tells the popover to redraw.
  fileprivate func refreshPopover() {
    popoverViewController.view.needsToDraw(popoverViewController.view.bounds)
    popoverViewController.view.display()
  }
  
  /// When the list of colors change, we have to create a new view with the right size
  /// to accomodate for this change.
  fileprivate func resetPopoverView() {
    popover.contentViewController!.view =
      JXColorGridView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: popoverRequiredFrameSize()),
                      belongsTo: self)
  }
  
  fileprivate func setup() {
    // Configure the button's layer
    wantsLayer = true
    layer = CALayer()
    layer!.delegate = self
    // Configure the border properties:
    layer!.cornerRadius = borderRadius
    layer!.borderColor = borderColor
    layer!.borderWidth = borderWidth
    // Configure the background:
    layer!.backgroundColor = color.cgColor
    layer!.shadowOffset = CGSize(width: 0, height: -0.5)
    layer!.shadowColor = NSColor.black.cgColor
    layer!.shadowRadius = 0
    layer!.shadowOpacity = 0.2
    configureColorPanel()
    // Configure our popover:
    popover.contentViewController = popoverViewController
    
    layer!.setNeedsDisplay()
  }
  
  
  /// Configures the button--only needs to be called once.
  fileprivate func configure() {
    if darkMode {
      popover.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
    } else {
      popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
    }
    resetPopoverView()
  }
  
  /// Calculates the size a popover will need to be to properly
  /// display all the colors properly.
  fileprivate func popoverRequiredFrameSize() -> NSSize {
    var verticalSpace =
      ((CGFloat(rows) * (boxHeight + verticalBoxSpacing)) - verticalBoxSpacing + (2 * verticalMargin))
    if usesCustomColor { verticalSpace += menuHeight }
    if usesDefaultColor { verticalSpace += menuHeight }
    let horizontalSpace =
      ((CGFloat(columns) * (boxWidth + horizontalBoxSpacing)) - horizontalBoxSpacing + (2 * horizontalMargin))
    return NSMakeSize(horizontalSpace, verticalSpace)
  }
  
  /// Returns true if the specified color is listed in the color list.
  fileprivate func colorReferenced(_ color: NSColor) -> Bool {
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
  
  /// Returns the brightness of a specified color, between 0 and 1.
  /// - Parameter color: The color whose brightness is to be measured.
  func colorBrightness(_ color: NSColor) -> CGFloat {
    return color.usingColorSpaceName(NSCalibratedRGBColorSpace)!.brightnessComponent
  }
  
  /// Updates the template image
  fileprivate func updateImage() {
    if imageIsTemplate && image != nil {
      // Check the color of our background and make sure the
      let brightness = colorBrightness(color)
      if brightness >= 0.5 || color.alphaComponent <= 0.5 {
        icon = image!.tintedImage(imageNormalColor)
      } else {
        icon = image!.tintedImage(imageLightColor)
      }
      // Force a redraw:
      layer?.setNeedsDisplay()
    }
  }
  
  // MARK: Color Panel
  
  @objc fileprivate func colorFromPanel(_ sender: AnyObject?) {
    if !colorPanel.isVisible { return }
    // Look at the last JXColorButton to have focus and alter it accordingly.
    if let lastColorButton = JXColorButton.lastColorButton {
      lastColorButton.color = colorPanel.color
      lastColorButton.refreshPopover()
      if !lastColorButton.colorReferenced(colorPanel.color) {
        lastColorButton.customColor = colorPanel.color
      }
      lastColorButton.delegate?.colorSelected(self, color: lastColorButton.color)
    }
  }
  
  // MARK: Event Management
  
  override open func mouseUp(with theEvent: NSEvent?) {
    if theEvent != nil { super.mouseUp(with: theEvent!) }
    JXColorButton.lastColorButton = self
    colorPanel.setTarget(self)
    colorPanel.setAction(#selector(self.colorFromPanel(_:)))
    showColorPopover()
  }
  
  // MARK: Accessibility Support
  
  override open func accessibilityLabel() -> String? {
    return self.toolTip
  }
  
  override open func accessibilityPerformPress() -> Bool {
    self.mouseUp(with: nil)
    return true // Always handled, for now.
  }
}
