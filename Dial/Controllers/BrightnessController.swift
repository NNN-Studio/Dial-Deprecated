//
//  BrightnessController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import SFSafeSymbols

class BrightnessController: Controller {
    
    var id: ControllerID = .default(.brightness)
    
    var name: String = NSLocalizedString("Controllers/Default/Brigshtnes", value: "Brightness", comment: "brightness controller")
    
    var representingSymbol: SFSymbol {
        .sunMax
    }
    
    var haptics: Bool {
        true
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval, 
        _ callback: Dial.Callback
    ) {
        
    }
    
}
