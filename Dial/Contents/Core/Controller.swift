
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
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?)
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState, interval: TimeInterval?)
    
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
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?) {
        print("main click, double: \(isDoubleClick)")
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState, interval: TimeInterval?) {
        print("main rotation")
    }
    
}
