
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
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ deviceCallback: Device.Callback)
    
    func onRotation(rotation: Dial.Rotation, totalDegrees: Int, buttonState: Device.ButtonState, interval: TimeInterval?, _ deviceCallback: Device.Callback)
    
}

extension Controller {
    
    var haptics: Bool {
        false
    }
    
}

class DefaultController: Controller {
    
    
    var haptics: Bool {
        true
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ deviceCallback: Device.Callback) {
        print("main click, double: \(isDoubleClick)")
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?,
        _ deviceCallback: Device.Callback
    ) {
        print("main rotation")
    }
    
}
