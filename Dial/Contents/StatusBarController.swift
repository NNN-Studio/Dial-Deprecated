
import Foundation
import AppKit
import Defaults
import LaunchAtLogin

struct MenuItems {
    
    private let statusBarController: StatusBarController
    
    let connectionStatus = NSMenuItem()
    
    var controllers: [ControllerOptionItem] {
        Controllers.activatedControllers
            .map { controller in
                let item = ControllerOptionItem(controller.name, controller: controller)
                
                item.target = statusBarController
                item.action = #selector(statusBarController.setController(_:))
                
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
            option.target = statusBarController
            option.action = #selector(statusBarController.setSensitivity(_:))
            
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
            option.target = statusBarController
            option.action = #selector(statusBarController.setDirection(_:))
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
        
        item.target = statusBarController
        item.action = #selector(statusBarController.setHaptics(_:))
        
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
    
    
    
    init(_ statusBarController: StatusBarController) {
        self.statusBarController = statusBarController
        initActions()
        updateConnectionStatus(false)
    }
    
    private func initActions() {
        connectionStatus.target = statusBarController
        connectionStatus.action = #selector(statusBarController.reconnect(_:))
        connectionStatus.offStateImage = NSImage(
            systemSymbolName: "arrow.triangle.2.circlepath",
            accessibilityDescription: nil
        )!
        
        startsWithMacOS.target = statusBarController
        startsWithMacOS.action = #selector(statusBarController.setStartsWithMacOS(_:))
        
        openSettings.target = statusBarController
        openSettings.action = #selector(statusBarController.openSettings(_:))
        
        quit.target = statusBarController
        quit.action = #selector(statusBarController.quitApp(_:))
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

extension NSImage {
    
    func withVerticalPadding(_ padding: CGFloat) -> NSImage {
        let scalar = 1 - min(1, padding / size.width)
        let innerSize = size.applying(CGAffineTransform(scaleX: scalar, y: scalar))
        let image = NSImage(size: NSSize(width: innerSize.width, height: size.height))
        
        image.lockFocus()
        
        draw(in: NSRect(
            origin: NSPoint(x: 0, y: padding / 2),
            size: innerSize
        ))
        
        image.unlockFocus()
        
        return image
    }
    
    func horizontallyCombine(with image: NSImage?, padding: CGFloat = 4) -> NSImage {
        if let image {
            let newSize = NSSize(width: size.width + padding + image.size.width, height: max(size.height, image.size.height))
            let combinedImage = NSImage(size: newSize)
            
            combinedImage.lockFocus()
            
            draw(at: NSZeroPoint, from: NSZeroRect, operation: .copy, fraction: 1.0)
            image.draw(
                at: NSPoint(
                    x: size.width + padding,
                    y: (newSize.height - image.size.height) / 2
                ),
                from: NSZeroRect,
                operation: .copy,
                fraction: 1.0
            )
            
            combinedImage.unlockFocus()
            
            return combinedImage
        } else {
            return self
        }
    }
    
    func fitIntoStatusBar() -> NSImage {
        let scalar = NSStatusBar.system.thickness / size.height
        let image = self
        
        image.size = size.applying(CGAffineTransform(scaleX: scalar, y: scalar))
        
        return image
    }
    
}

class StatusBarController: NSObject, NSMenuDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var menuItems: MenuItems?
    
    var menuManager: MenuManager?
    
    override init() {
        super.init()
        
        self.menuItems = MenuItems(self)
        self.menuManager = MenuManager(delegate: self) {
            var items: [MenuManager.MenuItemGroup] = []
            
            items.append(MenuManager.groupItems(menuItems!.connectionStatus))
            
            items.append(MenuManager.groupItems(
                title: NSLocalizedString("Menu/Title/Controller", value: "Controller", comment: "controller"),
                badge: NSLocalizedString("Menu/Title/Controller/Hint", value: "press and hold dial", comment: "controller hint"),
                menuItems!.controllers
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
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            updateIcon(false)
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
    
    func setControllerAndUpdate(_ controller: Controller) {
        Defaults[.currentControllerID] = controller.id
        
        DispatchQueue.main.async {
            self.updateIcon(AppDelegate.instance?.dial.device.isConnected ?? false)
            AppDelegate.instance?.dial.device.buzz()
        }
    }
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        updateIcon(isConnected)
        menuItems?.updateConnectionStatus(isConnected, serialNumber)
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
                setControllerAndUpdate(Controllers.currentController)
            } else {
                reconnect(nil)
            }
        } else {
            statusItem.menu = menuManager?.menu
            statusItem.button?.performClick(nil)
        }
    }
    
    @objc func reconnect(
        _ sender: Any?
    ) {
        AppDelegate.instance?.dial.reconnect()
    }
    
    @objc func setController(
        _ sender: Any?
    ) {
        guard let item = sender as? ControllerOptionItem
        else { return }
        
        setControllerAndUpdate(item.option)
    }
    
    @objc func setSensitivity(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let sensitivity = item.representedObject as? Sensitivity
        else { return }
        
        Defaults[.sensitivity] = sensitivity
    }
    
    @objc func setDirection(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Defaults[.direction] = direction
    }
    
    @objc func setHaptics(
        _ sender: Any?
    ) {
        let flag = !Defaults[.hapticsEnabled]
        
        Defaults[.hapticsEnabled] = flag
    }
    
    @objc func setStartsWithMacOS(
        _ sender: Any?
    ) {
        let flag = !Defaults.launchAtLogin
        
        Defaults.launchAtLogin = flag
        menuItems?.updateStartsWithMacOS()
    }
    
    @objc func openSettings(
        _ sender: Any?
    ) {
        SettingsWindowController.shared.showWindow(nil)
    }
    
    @objc func quitApp(
        _ sender: Any?
    ) {
        NSApplication.shared.terminate(self)
    }
    
}
