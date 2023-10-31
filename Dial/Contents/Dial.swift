
import Foundation
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device = Device()
    
    var statusBarController = StatusBarController()
    
    var controller: Controller {
        if defaultController.isAgent {
            return defaultController.instance
        } else {
            let item = (
                statusBarController.menuItems?.modes
                    .filter { $0.option == Data.dialMode }
                    .first
            )
            
            return item?.controller ?? defaultController.instance
        }
    }
    
    private var defaultController = (
        instance: DefaultController(),
        isAgent: false,
        dispatch: DispatchWorkItem {}
    )
    
    private var lastActions: (
        buttonPressed: Date?,
        buttonReleased: Date?,
        rotation: Date?
    )
    
    private var rotationBehavior = (
        started: false,
        degrees /* 360 per circle, positive values represent clockwise rotation */ : Int.zero
    )
    
    init() {
        device.inputHandler = self
        connect()
    }
    
}

extension Dial {
    
    enum Rotation {
        
        case continuous(Direction)
        
        case stepping(Direction)
        
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

extension Dial: InputHandler {
    
    func onConnectionStatusChanged(_ isConnected: Bool, _ serialNumber: String?) {
        statusBarController.onConnectionStatusChanged(isConnected, serialNumber)
    }
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState) {
        let pressInterval = Date.now.timeIntervalSince(lastActions.buttonPressed)
        let releaseInterval = Date.now.timeIntervalSince(lastActions.buttonReleased)
        
        switch buttonState {
        case .pressed:
            // Trigger press and hold
            defaultController.dispatch = DispatchWorkItem {
                self.defaultController.isAgent = true
                print("Main controller is now the agent.")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval, execute: defaultController.dispatch)
            
            lastActions.buttonPressed = .now
        case .released:
            defaultController.dispatch.cancel()
            if defaultController.isAgent { print("Main controller is no longer the agent.") }
            defaultController.isAgent = false
            
            let clickInterval = Date.now.timeIntervalSince(lastActions.buttonPressed)
            guard let clickInterval, clickInterval <= NSEvent.doubleClickInterval else { break }
            
            if let releaseInterval, releaseInterval <= NSEvent.doubleClickInterval {
                // Double click
                controller.onClick(isDoubleClick: true, interval: releaseInterval, device.callback)
                lastActions.buttonReleased = nil
            } else {
                // Click
                controller.onClick(isDoubleClick: false, interval: releaseInterval, device.callback)
                lastActions.buttonReleased = .now
            }
        }
    }
    
    func onRotation(_ direction: Direction, _ buttonState: Device.ButtonState) {
        let interval = Date.now.timeIntervalSince(lastActions.rotation)
        if let interval, interval > NSEvent.keyRepeatDelay {
            // Rotation ended
            rotationBehavior.started = false
            rotationBehavior.degrees = 0
            print("Rotation ended.")
        }
        
        let lastStep = rotationBehavior.degrees / Data.rotationGap
        rotationBehavior.degrees += direction.rawValue
        let currentStep = rotationBehavior.degrees / Data.rotationGap
        
        if !rotationBehavior.started {
            // Check threshold
            rotationBehavior.started = rotationBehavior.degrees.magnitude > Data.rotationThresholdDegrees
            if rotationBehavior.started {
                print("Rotation started.")
            }
        }
        
        if rotationBehavior.started {
            // Continuous rotation
            controller.onRotation(
                rotation: .continuous(direction), totalDegrees: rotationBehavior.degrees,
                buttonState: buttonState, interval: interval,
                device.callback
            )
            
            if lastStep != currentStep {
                // Stepping rotation
                controller.onRotation(
                    rotation: .stepping(direction), totalDegrees: rotationBehavior.degrees,
                    buttonState: buttonState, interval: interval,
                    device.callback
                )
                
                if controller.haptics {
                    device.buzz()
                }
            }
        }
        
        lastActions.rotation = .now
    }
    
}
