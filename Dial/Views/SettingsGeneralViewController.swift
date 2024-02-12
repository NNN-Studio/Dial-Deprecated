//
//  SettingsGeneralViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit

class SettingsGeneralViewController: NSViewController {
    
    // MARK: - Interactives
    
    @IBOutlet weak var switchHaptics: NSSwitch!
    
    @IBOutlet weak var popUpButtonDirection: NSPopUpButton!
    
    @IBOutlet weak var popUpButtonSensitivity: NSPopUpButton!
    
    @IBOutlet weak var switchAutoHidesIcon: NSSwitch!
    
    @IBOutlet weak var switchStartsWithMacOS: NSSwitch!
    
    
    
    @IBOutlet weak var buttonBluetooth: NSButton!
    
    @IBOutlet weak var buttonQuit: NSButton!
    
    @IBOutlet weak var buttonSourceCode: NSButton!
    
    // MARK: - Descriptives
    
    @IBOutlet weak var labelHaptics: NSTextField!
    
    @IBOutlet weak var labelDirection: NSTextField!
    
    @IBOutlet weak var labelSensitivity: NSTextField!
    
    @IBOutlet weak var labelAutoHidesIcon: NSTextField!
    
    @IBOutlet weak var labelStartsWithMacOS: NSTextField!
    
    
    
    @IBOutlet weak var imageDial: NSImageView!
    
    @IBOutlet weak var labelSerial: NSTextField!
    
    @IBOutlet weak var labelAutoHidesIconDescription: NSTextField!
    
}
