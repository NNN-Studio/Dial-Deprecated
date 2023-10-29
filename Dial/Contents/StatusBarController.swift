
import Foundation
import AppKit

extension NSMenuItem {
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
}

class MenuOptionItem<Type>: NSMenuItem {
    
    init(_ title: String, option: Type) {
        super.init(title: title, action: nil, keyEquivalent: "")
        self.representedObject = option
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var option : Type {
        self.representedObject as! Type
    }
    
}

class ControllerOptionItem: MenuOptionItem<DialMode> {
    
    let controller: Controller
    
    init(_ title: String, mode: DialMode, controller: Controller) {
        self.controller = controller
        super.init(title, option: mode)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class StateOptionItem: MenuOptionItem<NSControl.StateValue> {
    
    init(_ title: String) {
        super.init(title, option: .mixed)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NSMenuItem {
    
    var flag: Bool {
        get {
            state == .on
        }
        
        set(flag) {
            state = flag ? .on : .off
        }
    }
    
}

extension NSMenu {
    
    func addMenuItems(_ items: StatusBarController.MenuItems) {
        addItem(items.connectionStatus)
        
        addItem(items.sep0)
        
        addItem(items.sep0Title)
        
        
        
        items.modes.forEach { addItem($0) }
        
        addItem(items.sep1)
        
        
        
        items.sensitivity.submenu = NSMenu()
        for sensitivityOption in items.sensitivityOptions {
            items.sensitivity.submenu?.addItem(sensitivityOption)
        }
        addItem(items.sensitivity)
        
        items.direction.submenu = NSMenu()
        for scrollDirectionOption in items.directionOptions {
            items.direction.submenu?.addItem(scrollDirectionOption)
        }
        addItem(items.direction)
        
        addItem(items.sep2)
        
        
        
        addItem(items.haptics)
        
        addItem(items.sep3)
        
        
        
        addItem(items.startsWithMacOS)
        
        addItem(items.quit)
    }
    
}

class StatusBarController: NSObject, NSMenuDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let menuItems = MenuItems()
    
    private let dial: Dial
    
    private var mainController = (instance: MainController(), handled: false)
    private var controllerHandlingDispatch: DispatchWorkItem?
    
    private var lastActions: (
        mouseDown: Date?,
        mouseUp: Date?,
        rotation: Date?
    )
    private var buttonState = Dial.ButtonState.released
    
    struct MenuItems {
        
        let connectionStatus = NSMenuItem()
        
        let sep0 = NSMenuItem.separator()
        
        let sep0Title = NSMenuItem(title: NSLocalizedString("Menu/Sep0Title", value: "Dial Mode", comment: "dial mode"))
        
        
        
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
        
        let sep1 = NSMenuItem.separator()
        
        
        
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
        
        let sep2 = NSMenuItem.separator()
        
        
        
        let haptics = StateOptionItem(NSLocalizedString("Menu/Haptics", value: "Haptics", comment: "haptics"))
        
        let sep3 = NSMenuItem.separator()
        
        
        
        let startsWithMacOS = StateOptionItem(NSLocalizedString("Menu/StartsWithMacOS", value: "Starts with macOS", comment: "starts with macos"))
        
        let quit = NSMenuItem(title: NSLocalizedString("Menu/Quit", value: "Quit", comment: "quit"))
        
        
        
        func setDialMode(_ dialMode: DialMode) {
            modes.forEach {
                $0.flag = dialMode == $0.option
            }
        }
        
        func setSensitivity(_ sensitivity: Sensitivity) {
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
        
        func setDirection(_ direction: Direction) {
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
        
    }
    
    var controller: Controller {
        get {
            if mainController.handled {
                return mainController.instance
            } else {
                let item = (
                    menuItems.modes
                        .filter { $0.option == Data.dialMode }
                        .first
                )
                
                return item?.controller ?? mainController.instance
            }
        }
    }
    
    init( _ dial: Dial) {
        self.dial = dial
        super.init()
        
        statusItem.button?.appearsDisabled = true
        menu.autoenablesItems = false
        
        menuItems.connectionStatus.target = self
        menuItems.connectionStatus.action = #selector(reconnect(_:))
        menuItems.connectionStatus.offStateImage = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: nil)!
        
        menuItems.sep0Title.isEnabled = false
        if #available(macOS 14.0, *) {
            menuItems.sep0Title.badge = NSMenuItemBadge(string: NSLocalizedString("Menu/Sep0Title/Badge", value: "hold dial to cycle", comment: "dial mode badge"))
        }
        
        
        menuItems.modes.forEach {
            $0.target = self
            $0.action = #selector(setDialMode(_:))
        }
        menuItems.setDialMode(Data.dialMode)
        
        for option in menuItems.sensitivityOptions {
            option.target = self
            option.action = #selector(setSensitivity(_:))
        }
        menuItems.setSensitivity(Data.sensitivity)
        
        for option in menuItems.directionOptions {
            option.target = self
            option.action = #selector(setDirection(_:))
        }
        menuItems.setDirection(Data.direction)
        
        menuItems.haptics.target = self
        menuItems.haptics.action = #selector(setHaptics(_:))
        menuItems.haptics.flag = Data.haptics
        
        menuItems.startsWithMacOS.target = self
        menuItems.startsWithMacOS.action = #selector(setStartsWithMacOS(_:))
        menuItems.startsWithMacOS.flag = Data.startsWithMacOS
        
        menuItems.quit.target = self
        menuItems.quit.action = #selector(quitApp(_:))
        
        
        
        menu.addMenuItems(menuItems)
        menu.delegate = self
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateIcon()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateConnectionStatus()
        }
        
        dial.device.hapticsMode = { self.controller.hapticsMode() }
        
        dial.onButtonStateChanged = { [unowned self] state in
            buttonState = state
            let last = (
                down: lastActions.mouseDown == nil ? nil : Date.now.timeIntervalSince(lastActions.mouseDown!),
                up: lastActions.mouseUp == nil ? nil : Date.now.timeIntervalSince(lastActions.mouseUp!)
            )
            let isDoubleClick = last.down?.magnitude ?? 1 <= NSEvent.doubleClickInterval
            let isClick = last.down?.magnitude ?? 1 <= NSEvent.doubleClickInterval * 0.6
            
            switch state {
            case .pressed:
                controller.onMouseDown(last: last.down, isDoubleClick: isDoubleClick)
                dial.device.updateSensitivity()
                
                // Click and hold long to switch mode
                controllerHandlingDispatch = DispatchWorkItem { [self] in
                    controller.onHandle()
                    mainController.handled = true
                    dial.device.updateSensitivity()
                    
                    controller.onMouseDown(last: last.down, isDoubleClick: false)
                    dial.device.updateSensitivity()
                }
                
                if let controllerHandlingDispatch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval * 2, execute: controllerHandlingDispatch)
                }
                
                lastActions.mouseDown = .now
                break
            case .released:
                controller.onMouseUp(last: last.up, isClick: isClick)
                dial.device.updateSensitivity()
                
                mainController.handled = false
                dial.device.updateSensitivity()
                
                controllerHandlingDispatch?.cancel()
                
                lastActions.mouseUp = .now
                break
            }
        }
        
        dial.onRotation = { [unowned self] rotation, direction in
            controllerHandlingDispatch?.cancel()
            controller.onRotation(rotation, direction, last: lastActions.rotation?.timeIntervalSince(.now), buttonState: buttonState)
            lastActions.rotation = .now
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }
    
    private func updateConnectionStatus() {
        if dial.device.isConnected {
            let serialNumber = dial.device.serialNumber
            
            if #available(macOS 14.0, *) {
                menuItems.connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/On",
                    value: "Surface Dial",
                    comment: "[macOS >=14.0] if (connected)"
                )
                menuItems.connectionStatus.badge = NSMenuItemBadge(string: serialNumber)
            } else {
                menuItems.connectionStatus.title = String(
                    format: NSLocalizedString("Menu/ConnectionStatus/On/Alt", value: "Surface Dial: ", comment: "[macOS <14.0] if (connected)"),
                    serialNumber
                )
            }
            menuItems.connectionStatus.flag = true
            menuItems.connectionStatus.isEnabled = false
            
            statusItem.button?.appearsDisabled = false
        }
        
        else {
            if #available(macOS 14.0, *) {
                menuItems.connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/Off",
                    value: "Surface Dial",
                    comment: "[macOS >=14.0] if (!connected)"
                )
                menuItems.connectionStatus.badge = NSMenuItemBadge(string: NSLocalizedString(
                    "Menu/ConnectionStatus/Off/Badge",
                    value: "disconnected",
                    comment: "[macOS >=14.0] if (!connected) badge"
                ))
            } else {
                menuItems.connectionStatus.title = NSLocalizedString(
                    "Menu/ConnectionStatus/Off",
                    value: "Surface Dial disconnected",
                    comment: "if (!connected)"
                )
            }
            menuItems.connectionStatus.flag = false
            menuItems.connectionStatus.isEnabled = true
            
            statusItem.button?.appearsDisabled = true
        }
        
        updateIcon()
    }
    
    private func updateIcon() {
        if let button = statusItem.button {
            if !dial.device.isConnected {
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
        }
    }
    
}

extension StatusBarController {
    
    func setDialModeAndUpdate(_ mode: DialMode?) {
        if let mode {
            Data.dialMode = mode
            menuItems.setDialMode(mode)
            updateIcon()
            
            dial.device.updateSensitivity()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                AppDelegate.instance?.buzz()
            }
        }
    }
    
    @objc func toggle(
        _ sender: Any?
    ) {
        if let event = NSApp.currentEvent, event.type == .leftMouseUp {
            if dial.device.isConnected {
                setDialModeAndUpdate(Data.getCycledDialMode(1))
            } else {
                reconnect(nil)
            }
        } else {
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
        }
    }
    
    @objc func reconnect(
        _ sender: Any?
    ) {
        dial.stop()
        dial.start()
        updateConnectionStatus()
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
        menuItems.setSensitivity(sensitivity)
        dial.device.updateSensitivity()
    }
    
    @objc func setDirection(
        _ sender: Any?
    ) {
        guard
            let item = sender as? NSMenuItem,
            let direction = item.representedObject as? Direction
        else { return }
        
        Data.direction = direction
        menuItems.setDirection(direction)
    }
    
    @objc func setHaptics(
        _ sender: Any?
    ) {
        let flag = !Data.haptics
        
        Data.haptics = flag
        menuItems.haptics.flag = flag
        dial.device.updateSensitivity()
    }
    
    @objc func setStartsWithMacOS(
        _ sender: Any?
    ) {
        let flag = !Data.startsWithMacOS
        
        Data.startsWithMacOS = flag
        menuItems.startsWithMacOS.flag = flag
    }
    
    @objc func quitApp(
        _ sender: Any?
    ) {
        NSApplication.shared.terminate(self)
    }
    
}
