//
//  BrightnessController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import SFSafeSymbols

class BrightnessController: DefaultController {
    
    var id: ControllerID = .default(.brightness)
    
    var name: String = NSLocalizedString("Controllers/Default/Brigshtnes/Name", value: "Brightness", comment: "brightness controller name")
    
    var representingSymbol: SFSymbol = .sunMax
    
    var description: String = NSLocalizedString("Controllers/Default/Brigshtnes/Description", value: "Brightness", comment: "brightness controller description")
    
    var haptics: Bool = true
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval, 
        _ callback: Dial.Callback
    ) {
        
    }
    
}
