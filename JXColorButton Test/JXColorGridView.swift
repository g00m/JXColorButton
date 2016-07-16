//
//  ColorGridView.swift
//  JXColorButton
//
//  Created by Joseph Essin on 4/15/16.
//

import Cocoa

/// A special view for rendering colors inside
/// a popover that belongs to JEColorButton.
/// This is where the magic happens.
class JXColorGridView: NSView {
  
  // MARK: Properties
  
  /// The parent button whose properties we implement
  private(set) var parent: JXColorButton?
  
  /// Whether or not we can render menu items as selected.
  private(set) var canSelect: Bool = false
  
  /// This view uses flipped coordinates--top left is 0,0.
  override var flipped: Bool { get { return true } }
  
  /// Default menu rendering font.
  let menuFont = NSFont.systemFontOfSize(NSFont.systemFontSize())
  
  /// The color that is currently active.
  private(set) var selectedColor: NSColor?
  
  /// Mouse coordinates relative to this view
  private(set) var mouse: NSPoint?
  
  /// The state of the menu's selection.
  private(set) var menuSelectionState: JXColorGridViewSelectionType = .ColorGridSelection
  
  /// Mouse tracking tag
  var trackingTag: NSTrackingRectTag?
  
  /// X, Y, and Color of the selected color box.
  var selection: (CGFloat, CGFloat, NSColor)? = nil
  
  // MARK: Initializers
  
  /// Use this initializer inside of a JEColorButton to create a ColorGridView
  /// for the popover.
  /// - Parameter frame: The frame of the view (the entire popover)
  /// - Parameter belongsTo: The parent JEColorButton that owns the popover
  ///   that this view resides in.
  init(frame: NSRect, belongsTo: JXColorButton) {
    // Initialize everything else:
    super.init(frame: frame)
    
    // We need a parent button to read its properties so our view
    // shows itself appropriately.
    parent = belongsTo
    // Track mouse movement inside our view.
    trackingTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
  }
  
  override func setFrameSize(newSize: NSSize) {
    super.setFrameSize(newSize)
    if let tag = trackingTag {
      self.removeTrackingRect(tag)
    }
    trackingTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
  }
  
  /// Don't use this initializer.
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  // MARK: Methods
  
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)
    
    //Draw a background color for the popover, if desired (but not recommended)
    if let backgroundColor = parent!.popoverBackgroundColor {
      backgroundColor.setFill()
      NSBezierPath.fillRect(CGRect(x: -100, y: -100, width: self.bounds.size.width + 100, height: self.bounds.size.height + 100))
    }
    
    //let context: NSGraphicsContext = NSGraphicsContext.currentContext()!
    
    if parent!.usesDefaultColor {
      // Render our default color menu item.
      // If it's selected, render it as selected, as well.
      let isSelected: Bool = (menuSelectionState == .DefaultColorSelection) ? true : false
      if isSelected {
        // Render highlight
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: parent!.menuHeight)
        parent!.selectedMenuItemColor.setFill()
        NSBezierPath.fillRect(rect)
      }
      let title = parent!.defaultColorTitle
      let fontSize = menuTextSize(title)
      let y: CGFloat = (abs(parent!.menuHeight - fontSize.height) / 2.0)
      let boxY = (abs(parent!.menuHeight - parent!.boxHeight) / 2.0)
      
      drawMenuString(title, y: y, selected: isSelected)
      // Draw our box of color:
      drawColorBoxAt(CGPoint(x: parent!.horizontalMargin, y: boxY),
                     color: parent!.defaultColor, selected: isSelected)
    }
    
    // Render the grid of colors here.
    let menuHeight = parent!.menuHeight
    let xSpacing = parent!.horizontalBoxSpacing
    let ySpacing = parent!.verticalBoxSpacing
    let boxWidth = parent!.boxWidth
    let boxHeight = parent!.boxHeight
    let xMargin = parent!.horizontalMargin
    let yMargin = parent!.verticalMargin
    for row in 0..<parent!.rows {
      for column in 0..<parent!.columns {
        // Show each color
        let color = parent!.colors[row][column]
        let x = ((boxWidth + xSpacing) * CGFloat(column)) + xMargin
        let y = menuHeight + ((boxHeight + ySpacing) * CGFloat(row)) + yMargin

        drawColorBoxAt(CGPoint(x: x, y: y), color: color)
      }
    }
    
    // Draw the selection last so it's above everything else:
    if let (x, y, color) = selection {
      let rect = CGRect(x: x , y: y, width: parent!.boxWidth, height: parent!.boxHeight)
      let brightness = parent!.colorBrightness(color)
      if color.alphaComponent > 0.5 {
        if brightness < 0.5 { NSColor.whiteColor().setStroke() } else { NSColor.blackColor().setStroke() }
      } else {
        NSColor.blackColor().setStroke()
      }
      NSBezierPath.setDefaultLineWidth(parent!.selectedBoxBorderWidth)
      NSBezierPath.strokeRect(rect)
    }
    
    if parent!.usesCustomColor {
      // Render our custom color menu item.
      // If it's selected, render it as selected.
      let yStart: CGFloat = (self.bounds.height - parent!.menuHeight - ySpacing)
      var isSelected: Bool = (menuSelectionState == .CustomColorPanelDesired) ? true : false
      if isSelected {
        // Render highlight
        let rect = CGRect(x: 0, y: yStart, width: self.bounds.width, height: parent!.menuHeight + ySpacing)
        parent!.selectedMenuItemColor.setFill()
        NSBezierPath.fillRect(rect)
      }
      let title = parent!.customColorTitle
      let fontSize = menuTextSize(title)
      let y: CGFloat = yStart + (abs(self.bounds.height - yStart) - fontSize.height) / 2.0 - 1.0
      let boxY = yStart + (abs(self.bounds.height - yStart) - boxHeight) / 2.0
      drawMenuString(title, y: y, selected: isSelected)
      // Draw our box of color:
      if menuSelectionState == .CustomColorSelection { isSelected = true } else { isSelected = false }
      drawColorBoxAt(CGPoint(x: parent!.horizontalMargin, y: boxY),
                     color: parent!.customColor, selected: isSelected)
      
    }
  }
  
  // MARK: Mouse Events
  
  override func mouseEntered(theEvent: NSEvent) {
    super.mouseEntered(theEvent)
    
    menuSelectionState = .ColorGridSelection
    canSelect = true
    self.window!.acceptsMouseMovedEvents = true
    self.window!.makeFirstResponder(self) // Necessary
    selectedColor = nil
    self.setNeedsDisplayInRect(self.bounds)
    self.displayIfNeeded()
  }
  
  override func mouseExited(theEvent: NSEvent) {
    super.mouseExited(theEvent)
    
    canSelect = false
    super.mouseExited(theEvent)
    self.window!.acceptsMouseMovedEvents = false
    canSelect = false
    mouse = nil
    selectedColor = nil
    menuSelectionState = .ColorGridSelection
    self.setNeedsDisplayInRect(self.bounds)
    self.displayIfNeeded()
  }
  
  override func mouseDragged(theEvent: NSEvent) {
    mouseMoved(theEvent)
  }
  
  override func mouseMoved(theEvent: NSEvent) {
    super.mouseMoved(theEvent)
    
    var didSelect: Bool = false
    mouse = self.convertPoint(theEvent.locationInWindow, fromView: nil)
    
    menuSelectionState = .ColorGridSelection
    
    selectedColor = nil
    selection = nil
    
    if parent!.usesDefaultColor {
      // See if the default color menu item is selected:
      if mouse!.y >= 0 && mouse!.y <= parent!.menuHeight {
        menuSelectionState = .DefaultColorSelection
        didSelect = true
      }
    }
    
    if parent!.usesCustomColor && !didSelect {
      // See if the custom color menu item is selected:
      
      let yStart: CGFloat = (self.bounds.height - parent!.menuHeight - parent!.verticalBoxSpacing)
      let boxX = parent!.horizontalMargin
      let boxY = yStart + (abs(self.bounds.height - yStart) - parent!.boxHeight) / 2.0
      let boxEndX = boxX + parent!.boxWidth
      let boxEndY = boxY + parent!.boxHeight
      
      if mouse!.y >= yStart && mouse!.y <= self.bounds.height {
        // We're in the menu area for the custom color selection. See if it's inside the custom
        // color rectangle, or just on the menu option and handle it appropriately
        if (mouse!.x >= boxX) && (mouse!.x <= boxEndX) &&
          (mouse!.y >= boxY) && (mouse!.y <= boxEndY) {
          // We're inside the custom color rectangle itself, so we want to pick the color, not open
          // the color panel
          menuSelectionState = .CustomColorSelection
          didSelect = true
        } else {
          // We want to open a the system color panel picker
          menuSelectionState = .CustomColorPanelDesired
          didSelect = true
        }
      }
    }
    
    // If we haven't selected anything already, look for a collision in the grid.
    if !didSelect {
      selectedColor = nil
      outerSearch: for row in 0..<parent!.rows {
        for column in 0..<parent!.columns {
          let color = parent!.colors[row][column]
          let halfBorder: CGFloat = parent!.boxBorderWidth / 2.0
          
          let x = ((parent!.boxWidth + parent!.horizontalBoxSpacing) * CGFloat(column)) + parent!.horizontalMargin
          let y = parent!.menuHeight + ((parent!.boxHeight + parent!.verticalBoxSpacing) * CGFloat(row)) + parent!.verticalMargin
          
          if mouse!.x >= x - halfBorder && mouse!.x <= x + parent!.boxWidth + halfBorder &&
            mouse!.y >= y - halfBorder && mouse!.y <= y + parent!.boxHeight + halfBorder {
            // We're hovering over a color in the grid
            selectedColor = color
            selection = (x, y, color)
            didSelect = true
            menuSelectionState = .ColorGridSelection
            break outerSearch // Exit both for loops
          }
        }
      }
    }
    
    if didSelect {
      self.setNeedsDisplayInRect(self.bounds)
      self.displayIfNeeded()
    } else {
      menuSelectionState = .NoSelection
    }
  }
  
  override func mouseUp(theEvent: NSEvent) {
    let delegate = parent! as JXColorGridViewDelegate
    if menuSelectionState == .ColorGridSelection {
      delegate.colorWasSelected(self, color: selectedColor, selectionType: .ColorGridSelection)
    } else if menuSelectionState == .CustomColorPanelDesired {
      delegate.colorWasSelected(self, color: parent!.customColor, selectionType: .CustomColorPanelDesired)
    } else if menuSelectionState == .DefaultColorSelection {
      delegate.colorWasSelected(self, color: parent!.defaultColor, selectionType: .DefaultColorSelection)
    } else if menuSelectionState == .CustomColorSelection {
      delegate.colorWasSelected(self, color: parent!.customColor, selectionType: .CustomColorSelection)
    }
  }
  
  // MARK: Private Methods
  
  /// Draws a color box at the specified point.
  /// - Parameter point: The upper-left corner of the box in view coordinates.
  /// - Parameter color: The color of the box to draw.
  private func drawColorBoxAt(point: CGPoint, color: NSColor, selected: Bool = false) {
    let rect = CGRect(x: point.x , y: point.y, width: parent!.boxWidth, height: parent!.boxHeight)
    if color.isEqualToColor(NSColor.clearColor()) {
      // Clear color
      NSColor.whiteColor().setFill()
      NSBezierPath.setDefaultLineWidth(2.0)
      NSColor.redColor().setStroke()
      let line = NSBezierPath()
      line.moveToPoint(NSMakePoint(point.x, point.y + parent!.boxHeight))
      line.lineToPoint(NSMakePoint(point.x + parent!.boxWidth, point.y))
      line.stroke()
      NSBezierPath.fillRect(rect)
      line.stroke()
      adjustStrokeForSelection(selected)
      NSBezierPath.strokeRect(rect)
    } else {
      // Not clear color
      color.setFill()
      adjustStrokeForSelection(selected)
      NSBezierPath.fillRect(rect)
      NSBezierPath.strokeRect(rect)
    }
  }
  
  private func adjustStrokeForSelection(selected: Bool) {
    if selected {
      parent!.selectedBoxColor.setStroke()
      NSBezierPath.setDefaultLineWidth(parent!.selectedBoxBorderWidth)
    } else {
      parent!.boxBorderColor.setStroke()
      NSBezierPath.setDefaultLineWidth(parent!.boxBorderWidth)
    }
  }
  
  /// Draws a truncanted string as a menu label at the specified location.
  /// - Parameter string: The string to draw.
  /// - Parameter y: The vertical position to draw the string.
  /// - Parameter selected: True if the string is selected, false otherwise.
  private func drawMenuString(string: NSString, y: CGFloat, selected: Bool) {
    let str = UnwrappableString(string)
    let fontSize = menuTextSize(str)
    let x: CGFloat = (2.0 * parent!.horizontalBoxSpacing) + parent!.boxWidth + (parent!.horizontalMargin * 1.8)
    let width: CGFloat = self.bounds.width - x
    let height: CGFloat = min(parent!.menuHeight - y, fontSize.height)
    let rect: NSRect = NSRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width , height: height))
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .ByTruncatingTail
    var attributes: [String: AnyObject]? = [NSFontAttributeName: menuFont, NSParagraphStyleAttributeName: style]
    if selected {
      attributes![NSForegroundColorAttributeName] = parent!.selectedMenuItemTextColor
    } else {
      attributes![NSForegroundColorAttributeName] = parent!.textColor
    }
    str.drawWithRect(rect,
                     options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin],
                     attributes: attributes)
  }
  
  /// Calculates the size of given menu text given the width constraint of the popover.
  /// This is highly specific to the draw
  private func menuTextSize(string: NSString) -> CGSize {
    let str = UnwrappableString(string)
    let width: CGFloat = self.bounds.width - ((parent!.horizontalBoxSpacing * CGFloat(2.0)) + parent!.boxWidth)
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .ByTruncatingTail
    let attributes = [NSFontAttributeName: menuFont, NSParagraphStyleAttributeName: style]
    let rect: NSRect = str.boundingRectWithSize(NSMakeSize(width, CGFloat.max),
                                                options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin],
                                                attributes: attributes, context: nil)
    return rect.size
  }
  
  /// Returns a string that is immune to line-wrapping.
  private func UnwrappableString(string: NSString) -> NSString {
    let str: String = string.stringByReplacingOccurrencesOfString(" ",
      withString: "\u{a0}").stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
    return str
  }
}
