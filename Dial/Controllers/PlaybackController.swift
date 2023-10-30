import Foundation
import AppKit

class PlaybackController: Controller {
    
    func onClick(last: TimeInterval?, isDoubleClick: Bool) {
        if isDoubleClick {
            // Undo pause sent on first click
            postAuxKeys([Keyboard.keyPlay], modifiers: [], _repeat: 1)
            
            // Mute on double click
            postAuxKeys([Keyboard.keyMute], modifiers: [])
        } else {
            // Play / Pause on single click
            postAuxKeys([Keyboard.keyPlay], modifiers: [], _repeat: 1)
        }
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState, interval: TimeInterval?) {
        var modifiers: [NSEvent.ModifierFlags]
        var action: [Device.ButtonState: [Direction: (aux: [Int32], normal: [Int32])]] = [:]
        
        switch buttonState {
        case .pressed:
            modifiers = [NSEvent.ModifierFlags.shift, NSEvent.ModifierFlags.option]
            action[.pressed] = [.clockwise: (aux: [Keyboard.keyVolumeUp], normal: []), .counterclockwise: (aux: [Keyboard.keyVolumeDown], normal: [])]
            break
        case .released:
            modifiers = []
            action[.released] = [.clockwise: (aux: [], normal: [Keyboard.keyRightArrow]), .counterclockwise: (aux: [], normal: [Keyboard.keyLeftArrow])]
            break
        }
        
        /*
        postAuxKeys(action[buttonState]![direction.withRotation(rotation)]!.aux, modifiers: modifiers)
        postKeys(action[buttonState]![direction.withRotation(rotation)]!.normal, modifiers: modifiers)
         */
    }
    
}
