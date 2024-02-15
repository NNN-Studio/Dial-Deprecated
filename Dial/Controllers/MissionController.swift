//
//  MissionController.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation
import AppKit
import SFSafeSymbols

class MissionController: DefaultController {
    
    var id: ControllerID = .default(.mission)
    
    var name: String = NSLocalizedString("Controllers/Default/Mission/Name", value: "Mission", comment: "mission controller name")
    
    var representingSymbol: SFSymbol = .command
    
    var description: String = NSLocalizedString(
        "Controllers/Default/Mission/Description",
        value: """
You can iterate through App Switcher and activate the app windows through this controller.
""",
        comment: "mission controller description"
    )
    
    private var inMission = false
    
    private var escapeDispatch: DispatchWorkItem?
    
    var haptics: Bool = true
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        if !isDoubleClick {
            onRelease(callback)
        }
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        switch rotation {
        case .stepping(let direction):
            escapeDispatch?.cancel()
            inMission = true
            
            let modifiers: [Direction: NSEvent.ModifierFlags] = [.clockwise: [.command], .counterclockwise: [.shift, .command]]
            let action: [Direction: [Input]] = [.clockwise: [.keyTab], .counterclockwise: [.keyTab]]
            
            Input.postKeys(action[direction]!, modifiers: modifiers[direction]!)
            
            escapeDispatch = DispatchWorkItem {
                Input.keyEscape.post()
            }
            if let escapeDispatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval * 3, execute: escapeDispatch)
            }
        default:
            break
        }
    }
    
    func onRelease(_ callback: Dial.Callback) {
        if inMission {
            inMission = false
            escapeDispatch?.cancel()
            
            Input.keyReturn.post()
        }
    }
    
}
