
import Foundation
import AppKit

protocol Controller: AnyObject {
    
    // MARK: - Protocol
    
    func hapticsMode() -> Dial.HapticsMode
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool)
    
    func onMouseUp(last: TimeInterval?, isClick: Bool)
    
    func onRotation(_ rotation: Dial.Rotation, last: TimeInterval?, buttonState: Dial.ButtonState)
    
    func onHandle()
    
}

extension Controller {
    
    // MARK: - Default Implementations
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
    }
    
    func onHandle() {
    }
    
}

extension Controller {
    
    // MARK: - Extension Methods
    
    func postMouse(_ button: CGMouseButton, buttonState action: Dial.ButtonState) {
        let mousePos = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        
        let translatedMousePos = NSPoint(x: mousePos.x, y: screenHeight - mousePos.y)
        var mouseType: CGEventType?
        
        switch button {
        case .left:
            mouseType = action == .pressed ? .leftMouseDown : .leftMouseUp
            break
        case .right:
            mouseType = action == .pressed ? .rightMouseDown : .rightMouseUp
            break
        case .center:
            mouseType = action == .pressed ? .otherMouseDown : .otherMouseUp
            break
        @unknown default:
            break
        }
        
        if let mouseType {
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: mouseType,
                mouseCursorPosition: translatedMousePos,
                mouseButton: button
            )
            
            event?.post(tap: .cghidEventTap)
        }
    }
    
    // https://stackoverflow.com/a/55854051
    func postAuxKeys(_ keys: [Int32], modifiers: [NSEvent.ModifierFlags] = [], _repeat: Int = 1) {
        func doKey(_ key: Int32, down: Bool) {
            var rawFlags: UInt = (down ? 0xa00 : 0xb00);
            
            for modifier in modifiers {
                rawFlags |= modifier.rawValue
            }
            
            let flags = NSEvent.ModifierFlags(rawValue: rawFlags)
            
            let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))
            
            let ev = NSEvent.otherEvent(
                with: NSEvent.EventType.systemDefined,
                location: NSPoint(x:0,y:0),
                modifierFlags: flags,
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: 8,
                data1: data1,
                data2: -1
            )
            
            let cev = ev?.cgEvent
            cev?.post(tap: CGEventTapLocation.cghidEventTap)
        }
        
        for key in keys {
            for _ in 0..<_repeat {
                doKey(key, down: true)
                doKey(key, down: false)
            }
        }
    }
    
    func postKeys(_ keys: [Int32], modifiers: [NSEvent.ModifierFlags] = [], _repeat: Int = 1) {
        func doKey(_ key: Int32, down: Bool) {
            guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
                print("Failed to create event source")
                return
            }
            
            let ev = CGEvent(
                keyboardEventSource: eventSource,
                virtualKey: CGKeyCode(key),
                keyDown: down
            )
            ev?.flags = CGEventFlags(rawValue: (modifiers.reduce(0) { $0 | UInt64($1.rawValue) }))
            ev?.post(tap: .cghidEventTap)
        }
        
        for key in keys {
            for _ in 0..<_repeat {
                doKey(key, down: true)
                doKey(key, down: false)
            }
        }
    }
    
}
