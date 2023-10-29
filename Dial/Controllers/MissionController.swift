//
//  MissionController.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation
import AppKit

class MissionController: Controller {
    
    private var inMission = false
    
    func hapticsMode() -> Dial.HapticsMode {
        .none
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        if inMission && isClick {
            postKeys([Keyboard.keyReturn])
            inMission = false
        }
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?, buttonState: Dial.ButtonState) {
        inMission = true
        
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
            
            action[.released] = [.clockwise: [Keyboard.keyTab], .counterclockwise: [Keyboard.keyTab]]
            break
        }
        
        postKeys(action[buttonState]![direction.withRotation(rotation)]!, modifiers: modifiers)
        AppDelegate.instance?.dial.device.buzz()
    }
    
}
