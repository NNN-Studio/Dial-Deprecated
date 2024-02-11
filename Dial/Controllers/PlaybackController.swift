import Foundation
import AppKit

class PlaybackController: Controller {
    
    var id: ControllerID = .default(.playback)
    
    var name: String = NSLocalizedString("Controllers/Default/Playback", value: "Playback", comment: "playback controller")
    
    var icon: Icon = Icon("speaker.wave.2")!
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        if isDoubleClick {
            // Undo pause sent on first click
            Input.postAuxKeys([Input.keyPlay], modifiers: [], _repeat: 1)
            
            // Mute on double click
            Input.postAuxKeys([Input.keyMute], modifiers: [])
        } else {
            // Play / Pause on single click
            Input.postAuxKeys([Input.keyPlay], modifiers: [], _repeat: 1)
        }
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        var modifiers: [NSEvent.ModifierFlags]
        var action: [Device.ButtonState: [Direction: (aux: [Int32], normal: [Input])]] = [:]
        
        switch buttonState {
        case .pressed:
            modifiers = [NSEvent.ModifierFlags.shift, NSEvent.ModifierFlags.option]
            action[.pressed] = [
                .clockwise: (aux: [Input.keyVolumeUp], normal: []),
                .counterclockwise: (aux: [Input.keyVolumeDown], normal: [])
            ]
            break
        case .released:
            modifiers = []
            action[.released] = [
                .clockwise: (aux: [], normal: [Input.keyRightArrow]),
                .counterclockwise: (aux: [], normal: [Input.keyLeftArrow])
            ]
            break
        }
        
        Input.postAuxKeys(action[buttonState]![rotation.direction]!.aux, modifiers: modifiers)
        Input.postKeys(action[buttonState]![rotation.direction]!.normal, modifiers: modifiers)
    }
    
}
