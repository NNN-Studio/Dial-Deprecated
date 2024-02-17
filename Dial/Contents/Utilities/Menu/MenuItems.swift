//
//  MenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import Foundation
import AppKit
import Defaults

@objc protocol DialMenuDelegate: AnyObject, DialSubmenuDelegate, DialControllerMenuDelegate {
    
    @objc func setSensitivity(_ sender: Any?)
    
    @objc func setDirection(_ sender: Any?)
    
    @objc func toggleHaptics(_ sender: Any?)
    
    @objc func toggleStartsWithMacOS(_ sender: Any?)
    
    @objc func openSettings(_ sender: Any?)
    
    @objc func quitApp(_ sender: Any?)
    
    @objc func reconnect(_ sender: Any?)
    
}

struct MenuItems {
    
    let delegate: DialMenuDelegate
    
    let submenuItems: SubmenuItems
    
    let controllerMenuItems: ControllerMenuItems
    
    init(delegate: DialMenuDelegate) {
        self.delegate = delegate
        self.submenuItems = .init(delegate: delegate)
        self.controllerMenuItems = .init(delegate: delegate, source: .activated)
    }
    
    var connectionStatus: NSMenuItem {
        let item = NSMenuItem()
        
        item.target = delegate
        item.action = #selector(delegate.reconnect(_:))
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
    
    var sensitivity: NSMenuItem {
        let item = NSMenuItem(title: Localization.General.sensitivity.localizedTitle)
        
        item.submenu = NSMenu()
        submenuItems.sensitivityOptions.forEach(item.submenu!.addItem(_:))
        
        @Sendable func apply(_ value: Sensitivity) {
            item.badge = NSMenuItemBadge(string: value.localizedBadge)
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.sensitivity) {
                apply(value)
            }
        }
        
        apply(Defaults[.sensitivity])
        return item
    }
    
    var direction: NSMenuItem {
        let item = NSMenuItem(title: Localization.General.direction.localizedTitle)
        
        item.submenu = NSMenu()
        submenuItems.directionOptions.forEach(item.submenu!.addItem(_:))
        
        @Sendable func apply(_ value: Direction) {
            item.badge = NSMenuItemBadge(string: value.localizedBadge)
        }
        
        Task { @MainActor in
            for await value in Defaults.updates(.direction) {
                apply(value)
            }
        }
        
        apply(Defaults[.direction])
        return item
    }
    
    var haptics: StateOptionItem {
        let item = StateOptionItem(Localization.General.haptics.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.toggleHaptics(_:))
        
        Task { @MainActor in
            for await value in Defaults.updates(.hapticsEnabled) {
                item.flag = value
            }
        }
        
        return item
    }
    
    var startsWithMacOS: StateOptionItem {
        let item = StateOptionItem(Localization.General.startsWithMacOS.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.toggleStartsWithMacOS(_:))
        
        Task { @MainActor in
            for await value in Defaults.updates(.launchAtLogin) {
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
