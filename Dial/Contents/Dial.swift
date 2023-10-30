
import Foundation
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device = Device()
    
    var statusBarController = StatusBarController()
    
    var controller: Controller {
        if mainController.isAgent {
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
    
    private var mainController = (instance: MainController(), isAgent: false, dispatch: DispatchWorkItem {})
    
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
            // Trigger press and hold
            mainController.dispatch = DispatchWorkItem {
                self.mainController.isAgent = true
                print("Main controller is now the agent.")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval, execute: mainController.dispatch)
            
            lastActions.buttonPressed = .now
        case .released:
            mainController.dispatch.cancel()
            if mainController.isAgent { print("Main controller is no longer the agent.") }
            mainController.isAgent = false
            
            let clickInterval = Date.now.timeIntervalSince(lastActions.buttonPressed)
            guard let clickInterval, clickInterval <= NSEvent.doubleClickInterval else { break }
            
            if let releaseInterval, releaseInterval <= NSEvent.doubleClickInterval {
                // Double click
                controller.onClick(isDoubleClick: true, interval: releaseInterval)
                lastActions.buttonReleased = nil
            } else {
                // Click
                controller.onClick(isDoubleClick: false, interval: releaseInterval)
                lastActions.buttonReleased = .now
            }
        }
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState) {
        controller.onRotation(rotation, buttonState, interval: Date.now.timeIntervalSince(lastActions.rotation))
        lastActions.rotation = .now
    }
    
}
