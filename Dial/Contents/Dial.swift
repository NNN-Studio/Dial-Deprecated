
import Foundation
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device = Device()
    
    var statusBarController = StatusBarController()
    
    var controller: Controller {
        if mainController.handled {
            return mainController.instance
        } else {
            let item = (
                statusBarController.menuItems?.modes
                    .filter { $0.option == Data.dialMode }
                    .first
            )
            
            return item?.controller ?? mainController.instance
        }
    }
    
    private var mainController = (instance: MainController(), handled: false, dispatch: DispatchWorkItem {})
    
    private var lastActions: (
        buttonPressed: Date?,
        buttonReleased: Date?,
        rotation: Date?
    )
    
    init() {
        device.eventHandler = self
        connect()
    }
    
}

extension Dial {
    
    func connect() {
        device.start()
    }
    
    func disconnect() {
        device.stop()
    }
    
    func reconnect() {
        disconnect()
        connect()
    }
    
}

extension Dial: DeviceEventHandler {
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        statusBarController.onConnectionStatusChanged(isConnected, serialNumber)
    }
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState) {
        let pressInterval = Date.now.timeIntervalSince(lastActions.buttonPressed)
        let releaseInterval = Date.now.timeIntervalSince(lastActions.buttonReleased)
        
        switch buttonState {
        case .pressed:
            if let pressInterval, pressInterval > NSEvent.doubleClickInterval {
                // Press and hold
                mainController.dispatch = DispatchWorkItem {
                    self.mainController.handled = true
                }
            }
            lastActions.buttonPressed = .now
        case .released:
            mainController.handled = false
            
            let clickInterval = lastActions.buttonReleased?.timeIntervalSince(lastActions.buttonPressed)
            guard let clickInterval, clickInterval <= NSEvent.doubleClickInterval else { break }
            
            if let releaseInterval, releaseInterval <= NSEvent.doubleClickInterval {
                // Double click
                controller.onClick(interval: releaseInterval, isDoubleClick: true)
                lastActions.buttonReleased = nil
            } else {
                // Click
                controller.onClick(interval: releaseInterval, isDoubleClick: false)
                lastActions.buttonReleased = .now
            }
        }
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState) {
        controller.onRotation(rotation, buttonState, interval: Date.now.timeIntervalSince(lastActions.rotation))
        lastActions.rotation = .now
    }
    
}
