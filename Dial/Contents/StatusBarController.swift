
import Foundation
import AppKit

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
        haptics.flag = Data.haptics
        
        startsWithMacOS.target = controller
        startsWithMacOS.action = #selector(controller.setStartsWithMacOS(_:))
        startsWithMacOS.flag = Data.startsWithMacOS
        
        quit.target = controller
        quit.action = #selector(controller.quitApp(_:))
    }
    
    func updateDialMode(
        _ dialMode: DialMode = Data.dialMode
    ) {
        modes.forEach {
            $0.flag = dialMode == $0.option
        }
    }
    
    func updateSensitivity(
        _ sensitivity: Sensitivity = Data.sensitivity
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
        _ direction: Direction = Data.direction
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
        _ flag: Bool = Data.haptics
    ) {
        haptics.flag = flag
    }
    
    func updateStartsWithMacOS(
        _ flag: Bool = Data.startsWithMacOS
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
                    value: "Surface Dial",
                    comment: "[macOS >=14.0] if (connected)"
                )
                connectionStatus.badge = NSMenuItemBadge(string: serialNumber)
            } else {
                connectionStatus.title = String(
                    format: NSLocalizedString("Menu/ConnectionStatus/On/Alt", value: "Surface Dial: ", comment: "[macOS <14.0] if (connected)"),
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
                    value: "Surface Dial",
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

class StatusBarController: NSObject, NSMenuDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
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
                if !isConnected {
                    button.image = NSImage(named: NSImage.Name("Dial"))!
                }
                
                else {
                    switch Data.dialMode {
                    case .scroll:
                        button.image = NSImage(named: NSImage.Name("DialScroll"))!
                        break
                    case .playback:
                        button.image = NSImage(named: NSImage.Name("DialPlayback"))!
                        break
                    case .mission:
                        button.image = NSImage(named: NSImage.Name("DialMission"))!
                        break
                    }
                }
                
                button.appearsDisabled = !isConnected
            }
        }
    }
    
}

extension StatusBarController {
    
    func setDialModeAndUpdate(_ mode: DialMode?) {
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
        
        Data.sensitivity = sensitivity
        menuItems?.updateSensitivity()
    }
    
    @objc func setDirection(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Data.direction = direction
        menuItems?.updateDirection()
    }
    
    @objc func setHaptics(
        _ sender: Any?
    ) {
        let flag = !Data.haptics
        
        Data.haptics = flag
        menuItems?.updateHaptics()
    }
    
    @objc func setStartsWithMacOS(
        _ sender: Any?
    ) {
        let flag = !Data.startsWithMacOS
        
        Data.startsWithMacOS = flag
        menuItems?.updateStartsWithMacOS()
    }
    
    @objc func quitApp(
        _ sender: Any?
    ) {
        NSApplication.shared.terminate(self)
    }
    
}
