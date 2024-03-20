import Foundation
import AppKit
import SFSafeSymbols

class PlaybackController: DefaultController {
    
    var id: ControllerID = .default(.playback)
    
    var name: String = NSLocalizedString("Controllers/Default/Playback/Name", value: "Playback", comment: "playback controller name")
    
    var representingSymbol: SFSymbol = .speakerWave2
    
    var description: String = NSLocalizedString(
        "Controllers/Default/Playback/Description",
        value: """
You can trigger forward / backward by dialing, increase / decrease volume by dialing while pressing, toggle system play / pause by single clicking, and mute / unmute by double clicking through this controller.
""",
        comment: "playback controller description")
    
    var rotationType: Rotation.RawType = .continuous
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        if isDoubleClick {
            // Undo pause sent on first click
            Input.postAuxKeys([Input.keyPlay], modifiers: [])
            
            // Mute on double click
            Input.postAuxKeys([Input.keyMute], modifiers: [])
        } else {
            // Play / Pause on single click
            Input.postAuxKeys([Input.keyPlay], modifiers: [])
        }
    }
    
    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        switch rotation {
        case .continuous(let direction):
            var modifiers: NSEvent.ModifierFlags
            var action: [Device.ButtonState: [Direction: (aux: [Int32], normal: [Input])]] = [:]
            
            switch buttonState {
            case .pressed:
                modifiers = [.shift, .option]
                action[.pressed] = [
                    .clockwise: (aux: [Input.keyVolumeUp], normal: []),
                    .counterclockwise: (aux: [Input.keyVolumeDown], normal: [])
                ]
                break
            case .released:
                modifiers = []
                action[.released] = [
                    .clockwise: (aux: [], normal: [.keyRightArrow]),
                    .counterclockwise: (aux: [], normal: [.keyLeftArrow])
                ]
                break
            }
            
            Input.postAuxKeys(action[buttonState]![direction]!.aux, modifiers: modifiers)
            Input.postKeys(action[buttonState]![direction]!.normal, modifiers: modifiers)
        default:
            break
        }
    }
    
}
