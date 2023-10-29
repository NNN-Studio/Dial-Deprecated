//
//  MissionController.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation
import AppKit

class MissionController: Controller {
    
    func hapticsMode() -> Dial.HapticsMode {
        .none
    }
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        if isClick {
            postKey(keys: [0x24 /* Return */])
        }
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?, buttonState: Dial.ButtonState) {
        var modifiers: [NSEvent.ModifierFlags]
        var action: [Dial.ButtonState: [Direction: [Int32]]] = [:]
        
        switch buttonState {
        case .pressed:
            modifiers = []
            action[.pressed] = [.clockwise: [], .counterclockwise: []]
            break
        case .released:
            modifiers = [NSEvent.ModifierFlags.command]
            if direction.withRotation(rotation) == .counterclockwise {
                modifiers.append(NSEvent.ModifierFlags.shift)
            }
            
            action[.released] = [.clockwise: [0x30 /* Tab */], .counterclockwise: [0x30 /* Tab */]]
            break
        }
        
        postKey(keys: action[buttonState]![direction.withRotation(rotation)]!, modifiers: modifiers)
        AppDelegate.instance?.dial.device.buzz()
    }
    
}
