

import Foundation
import AppKit

// https://stackoverflow.com/a/55854051
func HIDPostAuxKey(key: Int32, modifiers: [NSEvent.ModifierFlags], _repeat: Int = 1) {
    func doKey(down: Bool) {
        var rawFlags: UInt = (down ? 0xa00 : 0xb00);
        
        for modifier in modifiers {
            rawFlags |= modifier.rawValue
        }
        
        let flags = NSEvent.ModifierFlags(rawValue: rawFlags)
        
        let data1 = Int((key<<16) | (down ? 0xa00 : 0xb00))
        
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
    
    for _ in 0..<_repeat {
        doKey(down: true)
        doKey(down: false)
    }
    
}


class PlaybackController : Controller {
    
    var willPlayDispatch: DispatchWorkItem?
    
    func hapticsMode() -> Dial.HapticsMode {
        .buzz
    }
    
    func onMouseDown(last: TimeInterval?) {
    }
    
    func onMouseUp(last: TimeInterval?) {
        // Next song on double click
        if let last, last.magnitude < 0.35 {
            // Undo pause sent on first click
            HIDPostAuxKey(key: NX_KEYTYPE_PLAY, modifiers: [], _repeat: 1)
            
            if willPlayDispatch == nil {
                HIDPostAuxKey(key: NX_KEYTYPE_NEXT, modifiers: [])
            } else {
                willPlayDispatch?.cancel()
            }
        } else {
            // Play / Pause on single click
            willPlayDispatch = DispatchWorkItem {
                HIDPostAuxKey(key: NX_KEYTYPE_PLAY, modifiers: [], _repeat: 1)
            }
            if let willPlayDispatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.willPlayDispatch?.perform()
                    self.willPlayDispatch = nil
                }
            }
        }
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?) {
        let modifiers = [NSEvent.ModifierFlags.shift, NSEvent.ModifierFlags.option]
        
        switch (rotation) {
        case .clockwise(let _repeat):
            HIDPostAuxKey(key: NX_KEYTYPE_SOUND_UP, modifiers: modifiers, _repeat: _repeat * direction.rawValue)
            break
        case .counterclockwise(let _repeat):
            HIDPostAuxKey(key: NX_KEYTYPE_SOUND_DOWN, modifiers: modifiers, _repeat: _repeat * direction.rawValue)
            break
        }
    }
    
}
