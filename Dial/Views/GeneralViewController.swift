//
//  GeneralViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit
import Defaults

class GeneralViewController: NSViewController {
    
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
    
    // MARK: - Others
    
    private var menuItems: MenuItems?
    
}

extension GeneralViewController {
    
    override func viewDidLoad() {
        menuItems = MenuItems(delegate: self)
        
        initDescriptives()
        initInteractives()
    }
    
    func initDescriptives() {
        labelHaptics.stringValue = Localization.General.haptics.localizedName
        labelDirection.stringValue = Localization.General.direction.localizedName
        labelSensitivity.stringValue = Localization.General.sensitivity.localizedName
        labelAutoHidesIcon.stringValue = Localization.General.autoHidesIcon.localizedName
        labelStartsWithMacOS.stringValue = Localization.General.startsWithMacOS.localizedName
        
        buttonQuit.title = Localization.quit.localizedName
        
        let directionMenu = NSMenu()
        menuItems?.directionOptions.forEach(directionMenu.addItem(_:))
        popUpButtonDirection.menu = directionMenu
        
        let sensitivityMenu = NSMenu()
        menuItems?.sensitivityOptions.forEach(sensitivityMenu.addItem(_:))
        popUpButtonDirection.menu = sensitivityMenu
    }
    
    func initInteractives() {
        Task {
            for await value in Defaults.updates(.hapticsEnabled) {
                switchHaptics.flag = value
            }
        }
        
        Task {
            for await value in Defaults.updates(.autoHidesIconEnabled) {
                switchHaptics.flag = value
            }
        }
    }
    
}

extension GeneralViewController: DialMenuDelegate {
    
    func setController(_ sender: Any?) {
        <#code#>
    }
    
    func setSensitivity(_ sender: Any?) {
        <#code#>
    }
    
    func setDirection(_ sender: Any?) {
        <#code#>
    }
    
    func setHaptics(_ sender: Any?) {
        <#code#>
    }
    
    func setStartsWithMacOS(_ sender: Any?) {
        <#code#>
    }
    
}
