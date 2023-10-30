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
    
    private var escapeDispatch: DispatchWorkItem?
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?) {
        print("mission click, double: \(isDoubleClick)")
        /*
        if inMission {
            inMission = false
            escapeDispatch?.cancel()
            postKeys([Keyboard.keyReturn])
        }
         */
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState, interval: TimeInterval?) {
        print("mission rotation")
        /*
        escapeDispatch?.cancel()
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.instance?.dial.device.buzz()
        }
        
        escapeDispatch = DispatchWorkItem {
            self.postKeys([Keyboard.keyEscape])
        }
        if let escapeDispatch {
            DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval * 3, execute: escapeDispatch)
        }
         */
    }
    
}
