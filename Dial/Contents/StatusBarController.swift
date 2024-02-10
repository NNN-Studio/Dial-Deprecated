
import Foundation
import AppKit
import Defaults

struct MenuItems {
    
    let connectionStatus = NSMenuItem()
    
    let modes = [
        ControllerOptionItem(
            NSLocalizedString("Menu/DialMode/Scroll", value: "Scroll", comment: "dial mode scroll"),
            mode: .scroll,
            controller: ScrollController()
        ),
        ControllerOptionItem(
            NSLocalizedString("Menu/DialMode/Playback", value: "Playback", comment: "dial mode playback"),
            mode: .playback,
            controller: PlaybackController()
        ),
        ControllerOptionItem(
            NSLocalizedString("Menu/DialMode/Mission", value: "Mission", comment: "dial mode mission"),
            mode: .mission,
            controller: MissionController()
        )
    ]
    
    let sensitivity = NSMenuItem(title: NSLocalizedString("Menu/Sensitivity", value: "Sensitivity", comment: "sensitivity"))
    
    let sensitivityOptions = [
        MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Low", value: "Low", comment: "low"), option: .low),
        MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Medium", value: "Medium", comment: "medium"), option: .medium),
        MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Natural", value: "Natural", comment: "natural"), option: .natural),
        MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/High", value: "High", comment: "high"), option: .high),
        MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Extreme", value: "Extreme", comment: "extreme"), option: .extreme)
    ]
    
    let direction = NSMenuItem(title: NSLocalizedString("Menu/Direction", value: "Direction", comment: "direction"))
    
    let directionOptions = [
        MenuOptionItem<Direction>(NSLocalizedString("Menu/Direction/Clockwise", value: "Clockwise", comment: "clockwise"), option: .clockwise),
        MenuOptionItem<Direction>(NSLocalizedString("Menu/Direction/Counterclockwise", value: "Counterclockwise", comment: "counterclockwise"), option: .counterclockwise)
    ]
    
    let haptics = StateOptionItem(NSLocalizedString("Menu/Haptics", value: "Haptics", comment: "haptics"))
    
    let startsWithMacOS = StateOptionItem(NSLocalizedString("Menu/StartsWithMacOS", value: "Starts with macOS", comment: "starts with macos"))
    
    let openSettings = NSMenuItem(title: NSLocalizedString("Menu/OpenSettings", value:"Open Settings", comment: "open settings"))
    
    let quit = NSMenuItem(title: NSLocalizedString("Menu/Quit", value: "Quit", comment: "quit"))
    
    
    
    init(_ controller: StatusBarController) {
        initActions(controller)
        
        sensitivity.submenu = NSMenu()
        sensitivityOptions.forEach(sensitivity.submenu!.addItem(_:))
        
        direction.submenu = NSMenu()
        directionOptions.forEach(direction.submenu!.addItem(_:))
        
        updateDialMode()
        updateSensitivity()
        updateDirection()
        updateConnectionStatus(false)
    }
    
    private func initActions(_ controller: StatusBarController) {
        connectionStatus.target = controller
        connectionStatus.action = #selector(controller.reconnect(_:))
        connectionStatus.offStateImage = NSImage(
            systemSymbolName: "arrow.triangle.2.circlepath",
            accessibilityDescription: nil
        )!
        
        modes.forEach {
            $0.target = controller
            $0.action = #selector(controller.setDialMode(_:))
        }
        
        for option in sensitivityOptions {
            option.target = controller
            option.action = #selector(controller.setSensitivity(_:))
        }
        
        for option in directionOptions {
            option.target = controller
            option.action = #selector(controller.setDirection(_:))
        }
        
        haptics.target = controller
        haptics.action = #selector(controller.setHaptics(_:))
        haptics.flag = Defaults[.hapticsEnabled]
        
        startsWithMacOS.target = controller
        startsWithMacOS.action = #selector(controller.setStartsWithMacOS(_:))
        startsWithMacOS.flag = Defaults.launchAtLogin
        
        openSettings.target = controller
        openSettings.action = #selector(controller.openSettings(_:))
        
        quit.target = controller
        quit.action = #selector(controller.quitApp(_:))
    }
    
    func updateDialMode(
        _ dialMode: DefaultDialMode = Data.dialMode
    ) {
        modes.forEach {
            $0.flag = dialMode == $0.option
        }
    }
    
    func updateSensitivity(
        _ sensitivity: Sensitivity = Defaults[.senstivity]
    ) {
        sensitivityOptions
            .forEach { $0.flag = $0.option == sensitivity }
        
        if #available(macOS 14.0, *) {
            let badge = switch sensitivity {
            case .low:
                NSLocalizedString("Menu/Sensitivity/Badge/Low", value: "low", comment: "sensitivity badge low")
            case .medium:
                NSLocalizedString("Menu/Sensitivity/Badge/Medium", value: "medium", comment: "sensitivity badge medium")
            case .natural:
                NSLocalizedString("Menu/Sensitivity/Badge/Natural", value: "natural", comment: "sensitivity badge natural")
            case .high:
                NSLocalizedString("Menu/Sensitivity/Badge/High", value: "high", comment: "sensitivity badge high")
            case .extreme:
                NSLocalizedString("Menu/Sensitivity/Badge/Extreme", value: "extreme", comment: "sensitivity badge extreme")
            }
            self.sensitivity.badge = NSMenuItemBadge(string: badge)
        }
    }
    
    func updateDirection(
        _ direction: Direction = Defaults[.direction]
    ) {
        directionOptions
            .forEach { $0.flag = $0.option == direction }
        
        if #available(macOS 14.0, *) {
            let badge = switch direction {
            case .clockwise:
                NSLocalizedString("Menu/Direction/Badge/Clockwise", value: "clockwise", comment: "direction badge clockwise")
            case .counterclockwise:
                NSLocalizedString("Menu/Direction/Badge/Counterclockwise", value: "counterclockwise", comment: "direction badge counterclockwise")
            }
            self.direction.badge = NSMenuItemBadge(string: badge)
        }
    }
    
    func updateHaptics(
        _ flag: Bool = Defaults[.hapticsEnabled]
    ) {
        haptics.flag = flag
    }
    
    func updateStartsWithMacOS(
        _ flag: Bool = Defaults.launchAtLogin
    ) {
        startsWithMacOS.flag = flag
    }
    
    func updateConnectionStatus(
        _ isConnected: Bool,
        _ serialNumber: String? = nil
    ) {
        if isConnected, let serialNumber {
            if #available(macOS 14.0, *) {
                connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/On",
                    value: "Dial",
                    comment: "[macOS >=14.0] if (connected)"
                )
                connectionStatus.badge = NSMenuItemBadge(string: serialNumber)
            } else {
                connectionStatus.title = String(
                    format: NSLocalizedString("Menu/ConnectionStatus/On/Alt", value: "Dial: ", comment: "[macOS <14.0] if (connected)"),
                    serialNumber
                )
            }
            connectionStatus.flag = true
            connectionStatus.isEnabled = false
        }
        
        else {
            if #available(macOS 14.0, *) {
                connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/Off",
                    value: "Dial",
                    comment: "[macOS >=14.0] if (!connected)"
                )
                connectionStatus.badge = NSMenuItemBadge(string: NSLocalizedString(
                    "Menu/ConnectionStatus/Off/Badge",
                    value: "disconnected",
                    comment: "[macOS >=14.0] if (!connected) badge"
                ))
            } else {
                connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/Off",
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
                title: NSLocalizedString("Menu/Title/DialMode", value: "Dial Mode", comment: "title dial mode"),
                badge: NSLocalizedString("Menu/Title/DialMode/Badge", value: "press and hold dial", comment: "title dial mode badge"),
                menuItems!.modes
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
                let dialIcon = NSImage(systemSymbolName: "hockey.puck.fill", accessibilityDescription: nil)?
                    .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 24, weight: .bold))?
                    .withVerticalPadding(4)
                
                var modeIconName = isConnected ? Data.dialMode.modeIconName : "ellipsis.circle.fill"
                
                let modeIcon = NSImage(systemSymbolName: modeIconName, accessibilityDescription: nil)?
                    .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 24, weight: .bold))?
                    .withVerticalPadding(4)
                
                let combinedIcon = (isConnected ? dialIcon?.horizontallyCombine(with: modeIcon) : dialIcon)?
                    .withVerticalPadding(2)
                combinedIcon?.isTemplate = true
                
                button.image = combinedIcon?.fitIntoStatusBar()
                button.appearsDisabled = !isConnected
            }
        }
    }
    
}

extension StatusBarController {
    
    func setDialModeAndUpdate(_ mode: DefaultDialMode?) {
        if let mode {
            Data.dialMode = mode
            menuItems?.updateDialMode()
            
            DispatchQueue.main.async {
                self.updateIcon(AppDelegate.instance?.dial.device.isConnected ?? false)
                AppDelegate.instance?.dial.device.buzz()
            }
        }
    }
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        updateIcon(isConnected)
        menuItems?.updateConnectionStatus(isConnected, serialNumber)
    }
    
}

extension StatusBarController {
    
    @objc func toggle(
        _ sender: Any?
    ) {
        if let event = NSApp.currentEvent, event.type == .leftMouseUp {
            if AppDelegate.instance?.dial.device.isConnected ?? false {
                setDialModeAndUpdate(Data.getCycledDialMode(1))
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
    
    @objc func setDialMode(
        _ sender: Any?
    ) {
        guard let item = sender as? ControllerOptionItem
        else { return }
        
        setDialModeAndUpdate(item.option)
    }
    
    @objc func setSensitivity(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let sensitivity = item.representedObject as? Sensitivity
        else { return }
        
        Defaults[.senstivity] = sensitivity
        menuItems?.updateSensitivity()
    }
    
    @objc func setDirection(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Defaults[.direction] = direction
        menuItems?.updateDirection()
    }
    
    @objc func setHaptics(
        _ sender: Any?
    ) {
        let flag = !Defaults[.hapticsEnabled]
        
        Defaults[.hapticsEnabled] = flag
        menuItems?.updateHaptics()
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
