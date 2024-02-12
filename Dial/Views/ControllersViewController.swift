//
//  SettingsControllersViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit

class ControllersViewController: NSViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var viewDialCircle: NSView!
    
    @IBOutlet weak var viewDefaultControllerLabels: NSStackView!
    
    @IBOutlet weak var viewControllerName: NSStackView!
    
    @IBOutlet weak var viewShortcuts1: NSStackView!
    
    @IBOutlet weak var viewShortcuts2: NSStackView!
    
    @IBOutlet weak var viewOptions1: NSStackView!
    
    @IBOutlet weak var viewOptions2: NSStackView!
    
    // MARK: - Interactives
    
    @IBOutlet weak var segmentedControlShortcutsAdvanced: NSSegmentedControl!
    
    
    
    @IBOutlet weak var popUpButtonControllerSelector: NSPopUpButton!
    
    @IBOutlet weak var switchControllerActivated: NSSwitch!
    
    @IBOutlet weak var buttonDeleteController: NSButton!
    
    @IBOutlet weak var buttonAddController: NSButton!
    
    
    
    @IBOutlet weak var textFieldControllerName: NSTextField!
    
    @IBOutlet weak var buttonIconChooser: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Keys1: NSButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts1Keys2: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers1: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Keys1: NSButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Modifiers2: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonShortcuts2Keys2: NSButton!
    
    
    
    @IBOutlet weak var popUpButtonRotationType: NSPopUpButton!
    
    @IBOutlet weak var switchHaptics: NSSwitch!
    
    @IBOutlet weak var switchPhysicalDirection: NSSwitch!
    
    @IBOutlet weak var switchAlternativeDirection: NSSwitch!
    
    // MARK: - Descriptives
    
    @IBOutlet weak var labelRotationType: NSTextField!
    
    @IBOutlet weak var labelHaptics: NSTextField!
    
    @IBOutlet weak var labelPhysicalDirection: NSTextField!
    
    @IBOutlet weak var labelAlternativeDirection: NSTextField!
    
    
    
    @IBOutlet weak var labelDefaultControllerDescription: NSTextField!
    
    @IBOutlet weak var labelSerial: NSTextField!
    
}
