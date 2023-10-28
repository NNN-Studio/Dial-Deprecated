
import Foundation
import AppKit

class ScrollController: Controller {
    
    enum Action {
        
        case up
        case down
        
    }
    
    private func sendMouse(button action: Action) {
        let mousePos = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        
        let translatedMousePos = NSPoint(x: mousePos.x, y: screenHeight - mousePos.y)
        
        let event = CGEvent(mouseEventSource: nil, mouseType: action == .down ? .leftMouseDown : .leftMouseUp, mouseCursorPosition: translatedMousePos, mouseButton: .left)
        
        event?.post(tap: .cghidEventTap)
    }
    
    func hapticsMode() -> Dial.HapticsMode {
        .continuous
    }
    
    func onMouseDown(last: TimeInterval?) {
        sendMouse(button: .down)
    }
    
    func onMouseUp(last: TimeInterval?) {
        sendMouse(button: .up)
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?) {
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
    
}
