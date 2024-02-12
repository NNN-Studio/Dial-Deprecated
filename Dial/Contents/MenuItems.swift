//
//  MenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import Foundation
import AppKit
import Defaults

@objc protocol DialMenuDelegate: AnyObject {
    
    @objc func setController(_ sender: Any?)
    
    @objc func setSensitivity(_ sender: Any?)
    
    @objc func setDirection(_ sender: Any?)
    
    @objc func setHaptics(_ sender: Any?)
    
    @objc func setStartsWithMacOS(_ sender: Any?)
    
    @objc func openSettings(_ sender: Any?)
    
    @objc func quitApp(_ sender: Any?)
    
    @objc func reconnect(_ sender: Any?)
    
}

struct MenuItems {
    
    let delegate: DialMenuDelegate
    
    var connectionStatus: NSMenuItem {
        let item = NSMenuItem()
        
        item.target = delegate
        item.action = #selector(delegate.reconnect(_:))
        item.offStateImage = NSImage(systemSymbol: .arrowTriangle2Circlepath)
        
        @Sendable func apply(_ value: Device.ConnectionStatus) {
            print(value)
            switch value {
            case .connected(let serialNumber):
                if #available(macOS 14.0, *) {
                    item.title = NSLocalizedString(
                        "ConnectionStatus/On",
                        value: "Dial",
                        comment: "[macOS >=14.0] if (connected)"
                    )
                    item.badge = NSMenuItemBadge(string: serialNumber)
                } else {
                    item.title = String(
                        format: NSLocalizedString(
                            "ConnectionStatus/On/Alt",
                            value: "Dial: ",
                            comment: "[macOS <14.0] if (connected)"
                        ),
                        serialNumber
                    )
                }
                
                item.flag = true
                item.isEnabled = false
            case .disconnected:
                if #available(macOS 14.0, *) {
                    item.title = NSLocalizedString(
                        "ConnectionStatus/Off",
                        value: "Dial",
                        comment: "[macOS >=14.0] if (!connected)"
                    )
                    item.badge = NSMenuItemBadge(string: NSLocalizedString(
                        "ConnectionStatus/Off/Badge",
                        value: "disconnected",
                        comment: "[macOS >=14.0] if (!connected) badge"
                    ))
                } else {
                    item.title = NSLocalizedString(
                        "ConnectionStatus/Off",
                        value: "Surface Dial disconnected",
                        comment: "if (!connected)"
                    )
                }
                
                item.flag = false
                item.isEnabled = true
            }
        }
        
        Task {
            for await value in observationTrackingStream({ AppDelegate.shared?.dial.device.connectionStatus }) {
                if let value { apply(value) }
            }
        }
        
        print(0)
        if let value = AppDelegate.shared?.dial.device.connectionStatus {
            print(1)
            apply(value)
        }
        
        return item
    }
    
    var controllers: [ControllerOptionItem] {
        Controllers.activatedControllers
            .map { controller in
                let item = ControllerOptionItem(controller.name, controller: controller)
                
                item.target = delegate
                item.action = #selector(delegate.setController(_:))
                
                Task {
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
        sensitivityOptions.forEach(item.submenu!.addItem(_:))
        
        Task {
            if #available(macOS 14.0, *) {
                for await value in Defaults.updates(.sensitivity) {
                    item.badge = NSMenuItemBadge(string: value.localizedBadge)
                }
            }
        }
        
        return item
    }
    
    var sensitivityOptions: [MenuOptionItem<Sensitivity>] {
        let options = [
            MenuOptionItem<Sensitivity>(Sensitivity.low.localizedName, option: .low),
            MenuOptionItem<Sensitivity>(Sensitivity.medium.localizedName, option: .medium),
            MenuOptionItem<Sensitivity>(Sensitivity.natural.localizedName, option: .natural),
            MenuOptionItem<Sensitivity>(Sensitivity.high.localizedName, option: .high),
            MenuOptionItem<Sensitivity>(Sensitivity.extreme.localizedName, option: .extreme)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setSensitivity(_:))
            
            Task {
                for await value in Defaults.updates(.sensitivity) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
    var direction: NSMenuItem {
        let item = NSMenuItem(title: Localization.General.direction.localizedTitle)
        
        item.submenu = NSMenu()
        directionOptions.forEach(item.submenu!.addItem(_:))
        
        Task {
            if #available(macOS 14.0, *) {
                for await value in Defaults.updates(.direction) {
                    item.badge = NSMenuItemBadge(string: value.localizedBadge)
                }
            }
        }
        
        return item
    }
    
    var directionOptions: [MenuOptionItem<Direction>] {
        let options = [
            MenuOptionItem<Direction>(Direction.clockwise.localizedName, option: .clockwise),
            MenuOptionItem<Direction>(Direction.counterclockwise.localizedName, option: .counterclockwise)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setDirection(_:))
            option.image = option.option.representingSymbol.raw
            
            Task {
                for await value in Defaults.updates(.direction) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
    var haptics: StateOptionItem {
        let item = StateOptionItem(Localization.General.haptics.localizedTitle)
        
        item.target = delegate
        item.action = #selector(delegate.setHaptics(_:))
        
        Task {
            for await value in Defaults.updates(.hapticsEnabled) {
                item.flag = value
            }
        }
        
        return item
    }
    
    let startsWithMacOS = StateOptionItem(Localization.General.startsWithMacOS.localizedTitle)
    
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
    
    private func initActions() {
        startsWithMacOS.target = delegate
        startsWithMacOS.action = #selector(delegate.setStartsWithMacOS(_:))
    }
    
    func updateStartsWithMacOS() {
        startsWithMacOS.flag = Defaults.launchAtLogin
    }
    
}
