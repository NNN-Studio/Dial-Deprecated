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
    
    private var submenuItems: SubmenuItems?
    
}

extension GeneralViewController {
    
    // MARK: - Storyboard Instantiation
    
    static func freshController() -> GeneralViewController {
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil
        )
        
        let identifier = NSStoryboard.SceneIdentifier("GeneralController")
        
        guard let controller = storyboard.instantiateController(
            withIdentifier: identifier
        ) as? GeneralViewController else {
            fatalError("Can not find GeneralController")
        }
        
        return controller
    }
    
}

extension GeneralViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submenuItems = SubmenuItems(delegate: self)
        
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
        submenuItems?.directionOptions.forEach(directionMenu.addItem(_:))
        popUpButtonDirection.menu = directionMenu
        
        let sensitivityMenu = NSMenu()
        submenuItems?.sensitivityOptions.forEach(sensitivityMenu.addItem(_:))
        popUpButtonSensitivity.menu = sensitivityMenu
        
        func applyConnectionStatus(_ value: Device.ConnectionStatus) {
            switch value {
            case .connected(let serialNumber):
                labelSerial.stringValue = serialNumber
                imageDial.isEnabled = true
            default:
                labelSerial.stringValue = Localization.ConnectionStatus.offOld.localizedName
                imageDial.isEnabled = false
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ AppDelegate.shared?.dial.device.connectionStatus }) {
                if let value { applyConnectionStatus(value) }
            }
        }
    }
    
    func initInteractives() {
        Task { @MainActor in
            for await value in Defaults.updates(.hapticsEnabled) {
                switchHaptics.flag = value
            }
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.direction) {
                let index = popUpButtonDirection.indexOfItem(withRepresentedObject: value)
                popUpButtonDirection.selectItem(at: index)
            }
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.sensitivity) {
                let index = popUpButtonSensitivity.indexOfItem(withRepresentedObject: value)
                popUpButtonSensitivity.selectItem(at: index)
            }
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.autoHidesIconEnabled) {
                switchAutoHidesIcon.flag = value
                labelAutoHidesIconDescription.isHidden = !value
            }
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.launchAtLogin) {
                switchStartsWithMacOS.flag = value
            }
        }
    }
    
}

extension GeneralViewController: DialSubmenuDelegate {
    
    @objc func setSensitivity(_ sender: Any?) {
        guard
            let item = sender as? NSMenuItem,
            let sensitivity = item.representedObject as? Sensitivity
        else { return }
        
        Defaults[.sensitivity] = sensitivity
    }
    
    @objc func setDirection(_ sender: Any?) {
        guard
            let item = sender as? NSMenuItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Defaults[.direction] = direction
    }
    
}

extension GeneralViewController {
    
    @IBAction func visitSourceCode(_ sender: Any?) {
        // TODO: Complete this
        print("Visited source code.")
    }
    
    @IBAction func reconnect(_ sender: Any?) {
        AppDelegate.shared?.dial.reconnect()
    }
    
}

extension GeneralViewController {
    
    @IBAction func toggleHaptics(_ sender: NSSwitch) {
        Defaults[.hapticsEnabled] = sender.flag
    }
    
    @IBAction func toggleDirection(_ sender: NSPopUpButton) {
        guard
            let item = sender.selectedItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Defaults[.direction] = direction
    }
    
    @IBAction func toggleSensitivity(_ sender: NSPopUpButton) {
        guard
            let item = sender.selectedItem,
            let sensitivity = item.representedObject as? Sensitivity
        else { return }
        
        Defaults[.sensitivity] = sensitivity
    }
    
    @IBAction func toggleAutoHidesIcon(_ sender: NSSwitch) {
        Defaults[.autoHidesIconEnabled] = sender.flag
    }
    
    @IBAction func toggleStartsWithMacOS(_ sender: NSSwitch) {
        Defaults[.launchAtLogin] = sender.flag
    }
    
    @IBAction func quitApp(_ sender: NSButton) {
        AppDelegate.quitApp()
    }
    
}
