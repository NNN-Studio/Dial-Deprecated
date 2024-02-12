//
//  MenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import Foundation
import AppKit
import Defaults

@objc protocol DialMenuDelegate: AnyObject, DialSubmenuDelegate {
    
    @objc func setController(_ sender: Any?)
    
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
    
    init(delegate: DialMenuDelegate) {
        self.delegate = delegate
        self.submenuItems = SubmenuItems(delegate: delegate)
    }
    
    var connectionStatus: NSMenuItem {
        let item = NSMenuItem()
        
        item.target = delegate
        item.action = #selector(delegate.reconnect(_:))
        item.offStateImage = NSImage(systemSymbol: .arrowTriangle2Circlepath)
        
        @Sendable func apply(_ value: Device.ConnectionStatus) {
            switch value {
            case .connected(let serialNumber):
                if #available(macOS 14.0, *) {
                    item.title = Localization.ConnectionStatus.on.localizedName
                    item.badge = NSMenuItemBadge(string: serialNumber)
                } else {
                    item.title = String(format: Localization.ConnectionStatus.onOld.localizedName, serialNumber)
                }
                
                item.flag = true
                item.isEnabled = false
            case .disconnected:
                if #available(macOS 14.0, *) {
                    item.title = Localization.ConnectionStatus.off.localizedName
                    item.badge = NSMenuItemBadge(string: Localization.ConnectionStatus.offBadge.localizedName)
                } else {
                    item.title = Localization.ConnectionStatus.offOld.localizedName
                }
                
                item.flag = false
                item.isEnabled = true
            }
        }
        
        Task { @MainActor in
            for await value in observationTrackingStream({ AppDelegate.shared?.dial.device.connectionStatus }) {
                if let value { apply(value) }
            }
        }
        
        return item
    }
    
    var controllers: [ControllerOptionItem] {
        Controllers.activatedControllers
            .map { controller in
                let item = ControllerOptionItem(controller.name, controller: controller)
                
                item.target = delegate
                item.action = #selector(delegate.setController(_:))
                
                Task { @MainActor in
                    for await value in Defaults.updates(.currentControllerID) {
                        item.flag = item.option.id == value
                    }
                }
                
                return item
            }
    }
    
    var sensitivity: NSMenuItem {
        let item = NSMenuItem(title: Localization.General.sensitivity.localizedTitle)
        
        item.submenu = NSMenu()
        submenuItems.sensitivityOptions.forEach(item.submenu!.addItem(_:))
        
        Task { @MainActor in
            if #available(macOS 14.0, *) {
                for await value in Defaults.updates(.sensitivity) {
                    item.badge = NSMenuItemBadge(string: value.localizedBadge)
                }
            }
        }
        
        return item
    }
    
    var direction: NSMenuItem {
        let item = NSMenuItem(title: Localization.General.direction.localizedTitle)
        
        item.submenu = NSMenu()
        submenuItems.directionOptions.forEach(item.submenu!.addItem(_:))
        
        Task { @MainActor in
            if #available(macOS 14.0, *) {
                for await value in Defaults.updates(.direction) {
                    item.badge = NSMenuItemBadge(string: value.localizedBadge)
                }
            }
        }
        
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
        
        return item
    }
    
    var quit: NSMenuItem {
        let item = NSMenuItem(title: Localization.quit.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.quitApp(_:))
        
        return item
    }
    
}
