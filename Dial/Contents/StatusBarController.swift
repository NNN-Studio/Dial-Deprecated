
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
        
        items.sep0Title.isEnabled = false
        addItem(items.sep0Title)
        
        
        
        addItem(items.scrollMode)
        addItem(items.playbackMode)
        
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
    
    struct MenuItems {
        
        let connectionStatus = NSMenuItem()
        
        let sep0 = NSMenuItem.separator()
        
        let sep0Title = NSMenuItem(title: NSLocalizedString("Menu/Sep0Title", value: "Dial Mode", comment: "dial mode"))
        
        
        
        let scrollMode = ControllerOptionItem(
            NSLocalizedString("Menu/DialMode/Scroll", value: "Scroll", comment: "dial mode scroll"),
            mode: .scroll,
            controller: ScrollController()
        )
        let playbackMode = ControllerOptionItem(
            NSLocalizedString("Menu/DialMode/Playback", value: "Playback", comment: "dial mode playback"),
            mode: .playback,
            controller: PlaybackController()
        )
        
        let sep1 = NSMenuItem.separator()
        
        
        
        let sensitivity = NSMenuItem(title: NSLocalizedString("Menu/Sensitivity", value: "Sensitivity", comment: "sensitivity"))
        let sensitivityOptions = [
            MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Low", value: "Low", comment: "low"), option: .low),
            MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/Natural", value: "Natural", comment: "natural"), option: .natural),
            MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/High", value: "High", comment: "high"), option: .high),
            MenuOptionItem<Sensitivity>(NSLocalizedString("Menu/Sensitivity/SuperHigh", value: "Super High", comment: "super high"), option: .superHigh),
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
            scrollMode.flag = dialMode == .scroll
            playbackMode.flag = dialMode == .playback
        }
        
        func setSensitivity(_ sensitivity: Sensitivity) {
            sensitivityOptions
                .forEach { $0.flag = $0.option == sensitivity }
        }
        
        func setDirection(_ direction: Direction) {
            directionOptions
                .forEach { $0.flag = $0.option == direction }
        }
        
    }
    
    var controller: Controller {
        get {
            if mainController.handled {
                return mainController.instance
            } else {
                return switch (Data.dialMode) {
                case .scroll:
                    menuItems.scrollMode.controller
                case .playback:
                    menuItems.playbackMode.controller
                }
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
        
        
        menuItems.scrollMode.target = self
        menuItems.scrollMode.action = #selector(setDialMode(_:))
        menuItems.scrollMode.flag = Data.dialMode == .scroll
        
        menuItems.playbackMode.target = self
        menuItems.playbackMode.action = #selector(setDialMode(_:))
        menuItems.playbackMode.flag = Data.dialMode == .playback
        
        for option in menuItems.sensitivityOptions {
            option.target = self
            option.action = #selector(setSensitivity(_:))
            option.flag = option.option == Data.sensitivity
        }
        
        for option in menuItems.directionOptions {
            option.target = self
            option.action = #selector(setDirection(_:))
            option.flag = option.option == Data.direction
        }
        
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
            switch state {
            case .pressed:
                controller.onMouseDown(last: lastActions.mouseDown?.timeIntervalSince(.now))
                
                controllerHandlingDispatch = DispatchWorkItem { [self] in
                    mainController.handled = true
                    dial.device.updateSensitivity()
                    controller.onMouseDown(last: lastActions.mouseDown?.timeIntervalSince(.now))
                }
                if let controllerHandlingDispatch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: controllerHandlingDispatch)
                }
                
                lastActions.mouseDown = .now
                break
            case .released:
                controller.onMouseUp(last: lastActions.mouseUp?.timeIntervalSince(.now))
                
                mainController.handled = false
                dial.device.updateSensitivity()
                controllerHandlingDispatch?.cancel()
                
                lastActions.mouseUp = .now
                break
            }
        }
        
        dial.onRotation = { [unowned self] rotation, direction in
            controller.onRotation(rotation, direction, last: lastActions.rotation?.timeIntervalSince(.now))
            lastActions.rotation = .now
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }
    
    private func updateConnectionStatus() {
        if dial.device.isConnected {
            let serialNumber = dial.device.serialNumber
            
            menuItems.connectionStatus.title = String(
                format: NSLocalizedString("Menu/ConnectionStatus/On", value: "Surface Dial: %@", comment: "if (connected)"),
                serialNumber
            )
            menuItems.connectionStatus.flag = true
            menuItems.connectionStatus.isEnabled = false
            
            statusItem.button?.appearsDisabled = false
        }
        
        else {
            menuItems.connectionStatus.title = NSLocalizedString("Menu/ConnectionStatus/Off", value: "Surface Dial disconnected", comment: "if (!connected)")
            menuItems.connectionStatus.flag = false
            menuItems.connectionStatus.isEnabled = true
            
            statusItem.button?.appearsDisabled = true
            
            updateIcon()
        }
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
                }
            }
            
            button.image?.size = NSSize(width: 22, height: 22)
            button.imagePosition = .imageOnly
        }
    }
    
}

extension StatusBarController {
    
    @objc func toggle(
        _ sender: Any?
    ) {
        if let event = NSApp.currentEvent, event.type == .leftMouseUp {
            if dial.device.isConnected {
                let _ = Data.cycleDialMode(1)
                Data.dialMode = Data.dialMode
                menuItems.setDialMode(Data.dialMode)
                updateIcon()
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
        
        let dialMode = item.option
        
        Data.dialMode = dialMode
        menuItems.setDialMode(dialMode)
        updateIcon()
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
