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
    
}

struct MenuItems {
    
    private let delegate: DialMenuDelegate
    
    let connectionStatus = NSMenuItem()
    
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
    
    let openSettings = NSMenuItem(title: Localization.openSettings.localizedTitle)
    
    let quit = NSMenuItem(title: Localization.quit.localizedTitle)
    
    
    
    init(delegate: DialMenuDelegate) {
        self.delegate = delegate
        
        initActions()
        updateConnectionStatus(false)
    }
    
    private func initActions() {
        connectionStatus.target = delegate
        connectionStatus.action = #selector(AppDelegate.reconnect(_:))
        connectionStatus.offStateImage = NSImage(
            systemSymbolName: "arrow.triangle.2.circlepath",
            accessibilityDescription: nil
        )!
        
        startsWithMacOS.target = delegate
        startsWithMacOS.action = #selector(delegate.setStartsWithMacOS(_:))
        
        openSettings.target = delegate
        openSettings.action = #selector(AppDelegate.openSettings(_:))
        
        quit.target = delegate
        quit.action = #selector(AppDelegate.quitApp(_:))
    }
    
    func updateStartsWithMacOS() {
        startsWithMacOS.flag = Defaults.launchAtLogin
    }
    
    func updateConnectionStatus(
        _ isConnected: Bool,
        _ serialNumber: String? = nil
    ) {
        if isConnected, let serialNumber {
            if #available(macOS 14.0, *) {
                connectionStatus.title = NSLocalizedString(
                    "ConnectionStatus/On",
                    value: "Dial",
                    comment: "[macOS >=14.0] if (connected)"
                )
                connectionStatus.badge = NSMenuItemBadge(string: serialNumber)
            } else {
                connectionStatus.title = String(
                    format: NSLocalizedString(
                        "ConnectionStatus/On/Alt",
                        value: "Dial: ",
                        comment: "[macOS <14.0] if (connected)"
                    ),
                    serialNumber
                )
            }
            connectionStatus.flag = true
            connectionStatus.isEnabled = false
        }
        
        else {
            if #available(macOS 14.0, *) {
                connectionStatus.title = NSLocalizedString(
                    "ConnectionStatus/Off",
                    value: "Dial",
                    comment: "[macOS >=14.0] if (!connected)"
                )
                connectionStatus.badge = NSMenuItemBadge(string: NSLocalizedString(
                    "ConnectionStatus/Off/Badge",
                    value: "disconnected",
                    comment: "[macOS >=14.0] if (!connected) badge"
                ))
            } else {
                connectionStatus.title = NSLocalizedString(
                    "ConnectionStatus/Off",
                    value: "Surface Dial disconnected",
                    comment: "if (!connected)"
                )
            }
            connectionStatus.flag = false
            connectionStatus.isEnabled = true
        }
    }
    
}
