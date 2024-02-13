import Foundation
import AppKit
import SFSafeSymbols

class ScrollController: DefaultController {
    
    var id: ControllerID = .default(.scroll)
    
    var name: String = NSLocalizedString("Controllers/Default/Scroll/Name", value: "Scroll", comment: "scroll controller description")
    
    var representingSymbol: SFSymbol = .arrowUpArrowDown
    
    var description: String = NSLocalizedString("Controllers/Default/Scroll/Description", value: "Scroll", comment: "scroll controller description")
    
    private var accumulated = 0
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        Input.postMouse(.center, buttonState: .pressed)
        Input.postMouse(.center, buttonState: .released)
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        var accelerated = false
        
        if let interval, interval <= 0.01 {
            if accumulated < 12 {
                accumulated += 1
            } else if duration > NSEvent.keyRepeatDelay {
                accelerated = true
            }
        } else {
            accumulated = 0
        }
        
        switch rotation {
        case .continuous(let direction):
            let steps = accelerated ? 45 : 5
            let event = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,
                wheelCount: 1,
                wheel1: Int32(steps * direction.negateIf(buttonState == .pressed).rawValue),
                wheel2: 0,
                wheel3: 0
            )
            event?.post(tap: .cghidEventTap)
        default:
            break
        }
    }
    
}
