//
//  LuminanceController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation

class LuminanceController: Controller {
    
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
