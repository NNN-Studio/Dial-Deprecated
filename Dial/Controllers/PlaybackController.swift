

import Foundation
import AppKit

class PlaybackController: Controller {
    
    func hapticsMode() -> Dial.HapticsMode {
        .buzz
    }
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        if isClick {
            if let last, last.magnitude < NSEvent.doubleClickInterval {
                // Mute on double click
                
                // Undo pause sent on first click
                postAuxKey(keys: [NX_KEYTYPE_PLAY], modifiers: [], _repeat: 1)
                postAuxKey(keys: [NX_KEYTYPE_MUTE], modifiers: [])
            } else {
                // Play / Pause on single click
                
                postAuxKey(keys: [NX_KEYTYPE_PLAY], modifiers: [], _repeat: 1)
            }
        }
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?, buttonState: Dial.ButtonState) {
        var modifiers: [NSEvent.ModifierFlags]
        var action: [Dial.ButtonState: [Direction: (aux: [Int32], normal: [Int32])]] = [:]
        
        switch buttonState {
        case .pressed:
            modifiers = [NSEvent.ModifierFlags.shift, NSEvent.ModifierFlags.option]
            action[.pressed] = [.clockwise: (aux: [NX_KEYTYPE_SOUND_UP], normal: []), .counterclockwise: (aux: [NX_KEYTYPE_SOUND_DOWN], normal: [])]
            break
        case .released:
            modifiers = []
            action[.released] = [.clockwise: (aux: [], normal: [0x7c /* → */]), .counterclockwise: (aux: [], normal: [0x7b /* ← */])]
            break
        }
        
        postAuxKey(keys: action[buttonState]![direction.withRotation(rotation)]!.aux, modifiers: modifiers)
        postKey(keys: action[buttonState]![direction.withRotation(rotation)]!.normal, modifiers: modifiers)
    }
    
}
