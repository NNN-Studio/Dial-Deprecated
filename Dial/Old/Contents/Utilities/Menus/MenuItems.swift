//
//  MenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import Foundation
import AppKit
import Defaults
import LaunchAtLogin

@objc protocol DialMenuDelegate: AnyObject, DialSubmenuDelegate, DialControllerMenuDelegate {
    
    @objc func setSensitivity(_ sender: Any?)
    
    @objc func setDirection(_ sender: Any?)
    
    @objc func toggleHaptics(_ sender: Any?)
    
    @objc func toggleStartsWithMacOS(_ sender: Any?)
    
    @objc func openSettings(_ sender: Any?)
    
    @objc func quitApp(_ sender: Any?)
    
    @objc func connect(_ sender: Any?)
    
}

class MenuItems {
    
    let delegate: DialMenuDelegate
    
    var submenuItems: SubmenuItems
    
    var controllerMenuItems: ControllerMenuItems
    
    init(delegate: DialMenuDelegate) {
        self.delegate = delegate
        self.submenuItems = .init(delegate: delegate)
        self.controllerMenuItems = .init(delegate: delegate, source: .activated)
        
        self.sensitivity = NSMenuItem(title: Localization.General.sensitivity.localizedTitle)
        self.direction = NSMenuItem(title: Localization.General.direction.localizedTitle)
        self.haptics = StateOptionItem(Localization.General.haptics.localizedTitle)
        
        initialize()
    }
    
    private func initialize() {
        sensitivity.submenu = NSMenu()
        submenuItems.sensitivityOptions.forEach(sensitivity.submenu!.addItem(_:))
        updateSensitivity(Defaults[.sensitivity])
        
        direction.submenu = NSMenu()
        submenuItems.directionOptions.forEach(direction.submenu!.addItem(_:))
        updateDirection(Defaults[.direction])
        
        haptics.target = delegate
        haptics.action = #selector(delegate.toggleHaptics(_:))
        updateHaptics(Defaults[.hapticsEnabled])
    }
    
    var connectionStatus: NSMenuItem {
        let item = NSMenuItem()
        
        item.target = delegate
        item.action = #selector(delegate.connect(_:))
        item.offStateImage = NSImage(systemSymbol: .arrowTriangle2Circlepath)
        
        @Sendable func apply(_ value: Device.ConnectionStatus) {
            switch value {
            case .connected(let serialNumber):
                item.title = Localization.ConnectionStatus.on.localizedName
                item.badge = NSMenuItemBadge(string: serialNumber)
                
                item.flag = true
                item.isEnabled = false
            case .disconnected:
                item.title = Localization.ConnectionStatus.off.localizedName
                item.badge = NSMenuItemBadge(string: Localization.ConnectionStatus.offBadge.localizedName)
                
                item.flag = false
                item.isEnabled = true
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ AppDelegate.shared?.dial.device.connectionStatus }) {
                if let value { apply(value) }
            }
        }
        
        apply(.disconnected)
        return item
    }
    
    var sensitivity: NSMenuItem
    
    var direction: NSMenuItem
    
    var haptics: StateOptionItem
    
    var startsWithMacOS: StateOptionItem {
        let item = StateOptionItem(Localization.General.startsWithMacOS.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.toggleStartsWithMacOS(_:))
        
        Task { @MainActor in
            for await value in observationTrackingStream({ LaunchAtLogin.observable.isEnabled }) {
                item.flag = value
            }
        }
        
        return item
    }
    
    var openSettings: NSMenuItem {
        let item = NSMenuItem(title: Localization.openSettings.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.openSettings(_:))
        
        item.keyEquivalent = ","
        item.keyEquivalentModifierMask = .command
        
        return item
    }
    
    var quit: NSMenuItem {
        let item = NSMenuItem(title: Localization.quit.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.quitApp(_:))
        
        item.keyEquivalent = "q"
        item.keyEquivalentModifierMask = .command
        
        return item
    }
    
}

extension MenuItems {
    
    func updateSensitivity(_ value: Sensitivity) {
        let icon = value.representingSymbol.unicode?.appending(" ") ?? ""
        sensitivity.badge = NSMenuItemBadge(string: icon + value.localizedBadge)
        
        submenuItems.updateSensitivityOptions(value)
    }
    
    func updateDirection(_ value: Direction) {
        let icon = value.representingSymbol.unicode?.appending(" ") ?? ""
        direction.badge = NSMenuItemBadge(string: icon + value.localizedBadge)
        
        submenuItems.updateDirectionOptions(value)
    }
    
    func updateHaptics(_ value: Bool) {
        haptics.flag = value
    }
    
}
