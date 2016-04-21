//
//  JXColorGridViewDelegate.swift
//  JEColorButton
//
//  Created by Joseph Essin on 4/16/16.
//

import Foundation
import Cocoa

/// What kind of color selection the user made inside the view.
@objc enum JXColorGridViewSelectionType: Int {
    /// A color was selected from the grid of colors
    case ColorGridSelection
    /// A color was selected from the default color
    case DefaultColorSelection
    /// A color was selected from the custom color menu option
    case CustomColorSelection
    /// A custom color selection is incoming, and the panel needs to be open
    case CustomColorPanelDesired
    /// Nothing was selected.
    case NoSelection
}

/// Allows the JXColorGridView to communicate with its parent JXColorButton.
@objc protocol JXColorGridViewDelegate {
    /// The user has chosen a color in the JXColorGridView and its ready to be dismissed.
    /// - Parameter sender: The JXColorGridView that the user chose a color from.
    /// - Parameter selectionType: What the context is of the color that was selected.
    @objc func colorWasSelected(sender: JXColorGridView, color: NSColor?, selectionType: JXColorGridViewSelectionType)
}