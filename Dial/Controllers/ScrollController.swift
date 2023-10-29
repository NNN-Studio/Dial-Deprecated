
import Foundation
import AppKit

class ScrollController: Controller {
    
    func hapticsMode() -> Dial.HapticsMode {
        .continuous
    }
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
        postMouse(.left, buttonState: .pressed)
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        postMouse(.left, buttonState: .released)
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?, buttonState: Dial.ButtonState) {
        postMouse(.left, buttonState: .released)
        
        var steps = 0
        
        switch rotation {
        case .clockwise(let d):
            steps = d
        case .counterclockwise(let d):
            steps = -d
        }
        
        steps *= direction.rawValue
        
        let diff = last ?? 0 * 1000
        let multiplier = Int(1 + ((150 - min(diff, 150)) / 40))
        
        let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .line,
            wheelCount: 1,
            wheel1: Int32(steps * multiplier),
            wheel2: 0,
            wheel3: 0
        )
        
        event?.post(tap: .cghidEventTap)
    }
    
    func onHandle() {
        postMouse(.left, buttonState: .released)
    }
    
}
