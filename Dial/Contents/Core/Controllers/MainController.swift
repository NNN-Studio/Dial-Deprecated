//
//  MainController.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import SFSafeSymbols

class MainController: Controller {
    
    var id: ControllerID = .default(.main)
    
    var name: String = NSLocalizedString("Controllers/Default/Main/Name", value: "Main", comment: "main controller")
    
    var representingSymbol: SFSymbol = .hockeyPuck
    
    var haptics: Bool = false
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        switch rotation {
        case .continuous(_):
            break
        case .stepping(let direction):
            Controllers.cycleThroughControllers(direction.physical.negate.rawValue)
            callback.setController(Controllers.currentController, animate: true)
            callback.device.buzz()
        }
    }
    
}
