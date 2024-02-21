import Foundation
import SFSafeSymbols
import Defaults
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device: Device = .init()
    
    var statusBarController: StatusBarController = .init()
    
    var window: DialWindow = .init(
        styleMask: [.borderless],
        backing: .buffered,
        defer: true
    )
    
    var controller: Controller {
        if mainController.isAgent {
            return mainController
        } else {
            let item = statusBarController.menuItems?.controllerMenuItems.controllers
                .filter { $0.option.id == Controllers.currentController.id }
                .first
            
            return item?.option ?? mainController
        }
    }
    
    private var mainController: MainController = .init()
    
    private var timestamps: (
        buttonPressed: Date?,
        buttonReleased: Date?,
        rotation: Date?
    )
    
    private var rotationBehavior: (
        started: Date?,
        direction: Direction,
        degrees /* 360 per circle, positive values represent clockwise rotation */ : Int
    ) = (started: nil, direction: .clockwise, degrees: 0)
    
    init() {
        device.inputHandler = self
        mainController.callback = .init(self)
        
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
    
}

extension Dial: InputHandler {
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState) {
        let pressInterval = Date.now.timeIntervalSince(timestamps.buttonPressed)
        let releaseInterval = Date.now.timeIntervalSince(timestamps.buttonReleased)
        
        rotationBehavior.started = nil
        rotationBehavior.degrees = 0
        
        switch buttonState {
        case .pressed:
            // Trigger press and hold
            if !mainController.isAgent {
                mainController.willBeAgent()
            }
            
            timestamps.buttonPressed = .now
        case .released:
            mainController.discardUpcomingAgentRole()
            
            let clickInterval = Date.now.timeIntervalSince(timestamps.buttonPressed)
            guard let clickInterval, clickInterval <= NSEvent.doubleClickInterval else {
                controller.onRelease(callback)
                break
            }
            
            if let releaseInterval, releaseInterval <= NSEvent.doubleClickInterval {
                // Double click
                controller.onClick(isDoubleClick: true, interval: releaseInterval, callback)
                timestamps.buttonReleased = nil
            } else {
                // Click
                controller.onClick(isDoubleClick: false, interval: releaseInterval, callback)
                timestamps.buttonReleased = .now
            }
        }
    }
    
    func onRotation(_ direction: Direction, _ buttonState: Device.ButtonState) {
        mainController.discardUpcomingAgentRole()
        
        let interval = Date.now.timeIntervalSince(timestamps.rotation)
        print(interval)
        if let interval, interval > NSEvent.keyRepeatDelay {
            // Rotation ended
            rotationBehavior.started = nil
            rotationBehavior.degrees = 0
            
            print("Rotation ended.")
        }
        
        let lastStage = (
            stepping: Int(CGFloat(rotationBehavior.degrees) / Defaults[.sensitivity].gap),
            continuous: Int(CGFloat(rotationBehavior.degrees) / Defaults[.sensitivity].flow)
        )
        rotationBehavior.degrees += direction.rawValue
        let currentStage = (
            stepping: Int(CGFloat(rotationBehavior.degrees) / Defaults[.sensitivity].gap),
            continuous: Int(CGFloat(rotationBehavior.degrees) / Defaults[.sensitivity].flow)
        )
        
        if let duration = Date.now.timeIntervalSince(rotationBehavior.started) {
            if lastStage.continuous != currentStage.continuous {
                // Continuous rotation
                controller.onRotation(
                    rotation: .continuous(direction), totalDegrees: rotationBehavior.degrees,
                    buttonState: buttonState, interval: interval, duration: duration,
                    callback
                )
            }
            
            if lastStage.stepping != currentStage.stepping {
                // Stepping rotation
                controller.onRotation(
                    rotation: .stepping(direction), totalDegrees: rotationBehavior.degrees,
                    buttonState: buttonState, interval: interval, duration: duration,
                    callback
                )
                
                if controller.haptics {
                    device.buzz()
                }
            }
            
            if rotationBehavior.direction != direction {
                rotationBehavior.direction = direction
                rotationBehavior.started = .now
            }
        } else {
            // Check threshold
            let started = rotationBehavior.degrees.magnitude > Defaults[.rotationThresholdDegrees]
            if started {
                print("Rotation started.")
                
                rotationBehavior.started = .now
            }
        }
        
        timestamps.rotation = .now
    }
    
}

extension Dial {
    
    var callback: Callback {
        Callback(self)
    }
    
    struct Callback {
        
        private var dial: Dial
        
        init(_ dial: Dial) {
            self.dial = dial
        }
        
        var device: Device.Callback {
            dial.device.callback
        }
        
        var window: DialWindow {
            dial.window
        }
        
    }
    
}
