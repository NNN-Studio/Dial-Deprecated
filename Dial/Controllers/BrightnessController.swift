//
//  BrightnessController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import SFSafeSymbols
import AppKit

class BrightnessController: DefaultController {
    
    var id: ControllerID = .default(.brightness)
    
    var name: String = NSLocalizedString("Controllers/Default/Brigshtnes/Name", value: "Brightness", comment: "brightness controller name")
    
    var representingSymbol: SFSymbol = .sunMax
    
    var description: String = NSLocalizedString(
        "Controllers/Default/Brigshtnes/Description",
        value: """
You can increase / decrease screen brightness by dialing, increase / decrease keyboard backlighting by dialing while pressing, and toggle keyboard backlighting by clicking through this controller.
""",
        comment: "brightness controller description"
    )
    
    var haptics: Bool = true
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        Input.postAuxKeys([Input.keyIlluminationToggle])
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
                    .clockwise: (aux: [Input.keyBrightnessUp], normal: []),
                    .counterclockwise: (aux: [Input.keyBrightnessDown], normal: [])
                ]
                break
            case .released:
                modifiers = []
                action[.released] = [
                    .clockwise: (aux: [Input.keyIlluminationUp], normal: []),
                    .counterclockwise: (aux: [Input.keyIlluminationDown], normal: [])
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
