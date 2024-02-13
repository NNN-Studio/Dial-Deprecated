
import Foundation
import AppKit
import Defaults
import LaunchAtLogin

class StatusBarController: NSObject, NSMenuDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var menuItems: MenuItems?
    
    var menuManager: MenuManager?
    
    override init() {
        super.init()
        
        self.menuItems = .init(delegate: self)
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            updateIcon(false)
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.currentControllerID) {
                updateIcon(AppDelegate.shared?.dial.device.isConnected ?? false)
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.activatedControllerIDs) {
                refreshMenuManager()
            }
        }
    }
    
    func refreshMenuManager() {
        self.menuManager = .init(delegate: self) {
            var items: [MenuManager.MenuItemGroup] = []
            
            items.append(MenuManager.groupItems(menuItems!.connectionStatus))
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString("Menu/Title/Controllers", value: "Controllers", comment: "controllers"),
                badge: NSLocalizedString("Menu/Title/ControllersHint", value: "press and hold dial", comment: "controllers hint"),
                menuItems!.controllerMenuItems.controllers
            ))
            
            items.append(MenuManager.groupItems(
                menuItems!.direction,
                menuItems!.sensitivity
            ))
            
            items.append(MenuManager.groupItems(
                menuItems!.haptics
            ))
            
            items.append(MenuManager.groupItems(
                menuItems!.startsWithMacOS,
                menuItems!.openSettings,
                menuItems!.quit
            ))
            
            return items
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }
    
    private func updateIcon(_ isConnected: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            if let button = statusItem.button {
                let dialIcon = SymbolRepresentation.dial.representingSymbol.raw
                    .withSymbolConfiguration(.init(pointSize: 26, weight: .bold))
                
                // TODO: DEBUG
                //let modeIcon = (isConnected ? Controllers.currentController.icon.filled : NSImage(systemSymbol: .ellipsisCircleFill) .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 24, weight: .bold)))?
                let modeIcon = Controllers.currentController.representingSymbol.circleFilled
                    .withSymbolConfiguration(.init(pointSize: 24, weight: .bold))!
                    .withVerticalPadding(2)
                
                // TODO: DEBUG
                //let combinedIcon = (isConnected ? dialIcon?.horizontallyCombine(with: modeIcon) : dialIcon)?
                let combinedIcon = dialIcon?.horizontallyCombine(with: modeIcon)
                    .withVerticalPadding(2)
                combinedIcon?.isTemplate = true
                
                button.image = combinedIcon?.fitIntoStatusBar()
                button.appearsDisabled = !isConnected
            }
        }
    }
    
}

extension StatusBarController {
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        updateIcon(isConnected)
    }
    
    func toggleVisibility(_ isVisible: Bool) {
        statusItem.isVisible = isVisible
    }
    
}

extension StatusBarController {
    
    @objc func toggle(
        _ sender: Any?
    ) {
        if let event = NSApp.currentEvent, event.type == .leftMouseUp {
            // TODO: DEBUG
            //if AppDelegate.instance?.dial.device.isConnected ?? false {
            if true {
                let sign = event.modifierFlags.contains(.shift) ? -1 : 1
                Controllers.cycleThroughControllers(sign)
            } else {
                DispatchQueue.main.async {
                    AppDelegate.shared?.dial.reconnect()
                }
            }
        } else {
            refreshMenuManager()
            statusItem.menu = menuManager!.menu
            statusItem.button?.performClick(nil)
        }
    }
    
}

extension StatusBarController: DialMenuDelegate {
    
    @objc func setController(_ sender: Any?) {
        guard let item = sender as? ControllerOptionItem else { return }
        
        Controllers.currentController = item.option
        DispatchQueue.main.async {
            AppDelegate.shared?.dial.device.buzz()
        }
    }
    
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
    
    @objc func toggleHaptics(_ sender: Any?) {
        Defaults[.hapticsEnabled].toggle()
    }
    
    @objc func toggleStartsWithMacOS(_ sender: Any?) {
        Defaults[.launchAtLogin].toggle()
    }
    
    func openSettings(_ sender: Any?) {
        AppDelegate.openSettings()
    }
    
    func quitApp(_ sender: Any?) {
        AppDelegate.quitApp()
    }
    
    func reconnect(_ sender: Any?) {
        DispatchQueue.main.async {
            AppDelegate.shared?.dial.reconnect()
        }
    }
    
}
