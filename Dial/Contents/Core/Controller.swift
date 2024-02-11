
import Foundation
import AppKit
import Defaults

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

enum ControllerID: Codable, Equatable, Defaults.Serializable {
    
    enum Default: CaseIterable, Codable {
        
        case main
        
        case scroll
        
        case playback
        
        case mission
        
        case brightness
        
        static var availableCases: [ControllerID.Default] {
            allCases.filter { $0 != .main }
        }
        
    }
    
    case id(UUID)
    
    case `default`(Default)
    
}

protocol Controller: AnyObject {
    
    var id: ControllerID { get }
    
    var name: String { get }
    
    var icon: Icon { get }
    
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

class MainController: Controller {
    
    var id: ControllerID = .default(.main)
    
    var name: String = NSLocalizedString("Controllers/Default/Main", value: "Main", comment: "main controller")
    
    var icon: Icon = Icon("hockey.puck")!
    
    var haptics: Bool = false
    
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
                direction.physical.negate.rawValue,
                wrap: false
            ) {
                callback.setDialModeAndUpdate(dialMode, animate: true)
                callback.device.buzz()
            }
        }
    }
    
}
