
import Foundation
import AppKit

extension Date {
    
    func timeIntervalSince(
        _ date: Date?
    ) -> TimeInterval? {
        if let date {
            return timeIntervalSince(date)
        } else {
            return nil
        }
    }
    
}

protocol Controller: AnyObject {
    
    /// Whether to enable haptic feedback on stepping. The default value is `false`.
    var haptics: Bool { get }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback)
    
    func onRotation(rotation: Dial.Rotation, totalDegrees: Int, buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval, _ callback: Dial.Callback)
    
    func onRelease(_ callback: Dial.Callback)
    
}

extension Controller {
    
    var haptics: Bool {
        false
    }
    
    func onRelease(_ callback: Dial.Callback) {}
    
}

class DefaultController: Controller {
    
    
    var haptics: Bool {
        false
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {}
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        switch rotation {
        case .continuous(_):
            break
        case .stepping(let direction):
            if let dialMode = Data.getCycledDialMode(
                direction.multiply(Data.direction) /* Recover to the natural direction */ .negate.rawValue,
                wrap: false
            ) {
                callback.setDialModeAndUpdate(dialMode, animate: true)
                callback.device.buzz()
            }
        }
    }
    
}
