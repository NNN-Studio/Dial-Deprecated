import Foundation
import SFSafeSymbols
import Defaults
import AppKit
import Cocoa
import SwiftUI

class Dial {
    
    var device = Device()
    
    var statusBarController = StatusBarController()
    
    var window = DialWindow(
        styleMask: [.borderless],
        backing: .buffered,
        defer: true
    )
    
    var controller: Controller {
        if defaultController.isAgent {
            return defaultController.instance
        } else {
            let item = statusBarController.menuItems?.controllerMenuItems.controllers
                .filter { $0.option.id == Controllers.currentController.id }
                .first
            
            return item?.option ?? defaultController.instance
        }
    }
    
    private var defaultController = (
        instance: MainController(),
        isAgent: false,
        dispatch: DispatchWorkItem {}
    )
    
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
        connect()
    }
    
}

extension Dial {
    
    enum Rotation: Codable {
        
        case continuous(Direction)
        
        case stepping(Direction)
        
        var type: RawType {
            switch self {
            case .continuous(_):
                .continuous
            case .stepping(_):
                .stepping
            }
        }
        
        var direction: Direction {
            switch self {
            case .continuous(let direction), .stepping(let direction):
                direction
            }
        }
        
        func conformsTo(_ type: RawType) -> Bool {
            self.type == type
        }
        
        enum RawType: Codable {
            
            case continuous
            
            case stepping
            
        }
        
    }
    
}

extension Dial.Rotation.RawType: Localizable {
    
    var localizedName: String {
        switch self {
        case .continuous:
            NSLocalizedString("Dial/Rotation/Type/Continuous.Name", value: "Continuous", comment: "continuous rotation type")
        case .stepping:
            NSLocalizedString("Dial/Rotation/Type/Stepping.Name", value: "Stepping", comment: "stepping rotation type")
        }
    }
    
    var localizedBadge: String {
        switch self {
        case .continuous:
            NSLocalizedString("Dial/Rotation/Type/Continuous.Badge", value: "continuous", comment: "continuous rotation type")
        case .stepping:
            NSLocalizedString("Dial/Rotation/Type/Stepping.Badge", value: "stepping", comment: "stepping rotation type")
        }
    }
    
}

extension Dial.Rotation.RawType: SymbolRepresentable {
    
    var representingSymbol: SFSymbol {
        switch self {
        case .continuous:
            .alternatingcurrent
        case .stepping:
            .directcurrent
        }
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
    
    func onButtonStateChanged(_ buttonState: Device.ButtonState) {
        let pressInterval = Date.now.timeIntervalSince(timestamps.buttonPressed)
        let releaseInterval = Date.now.timeIntervalSince(timestamps.buttonReleased)
        
        rotationBehavior.started = nil
        rotationBehavior.degrees = 0
        
        switch buttonState {
        case .pressed:
            // Trigger press and hold
            self.setDefaultControllerState(isAgent: true, deadline: .now() + NSEvent.doubleClickInterval)
            
            timestamps.buttonPressed = .now
        case .released:
            setDefaultControllerState(isAgent: false)
            
            let clickInterval = Date.now.timeIntervalSince(timestamps.buttonPressed)
            guard let clickInterval, clickInterval <= NSEvent.doubleClickInterval else {
                controller.onRelease(callback
                )
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
        let interval = Date.now.timeIntervalSince(timestamps.rotation)
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
            if !defaultController.isAgent {
                setDefaultControllerState(isAgent: false)
            }
            
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
    
    func setDefaultControllerState(
        isAgent: Bool,
        deadline: DispatchTime = .now()
    ) {
        if isAgent {
            defaultController.dispatch = DispatchWorkItem {
                self.defaultController.isAgent = true
                self.window.show()
                self.device.buzz()
                print("Default controller is now the agent.")
            }
            
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: defaultController.dispatch)
        } else {
            defaultController.dispatch.cancel()
            
            if defaultController.isAgent {
                defaultController.isAgent = false
                window.hide()
                print("Default controller is no longer the agent.")
            }
        }
    }
    
}

extension Dial {
    
    var callback: Callback {
        Callback(self)
    }
    
    struct Callback {
        
        private var dial: Dial
        
        var device: Device.Callback {
            dial.device.callback
        }
        
        init(_ dial: Dial) {
            self.dial = dial
        }
        
    }
    
}
