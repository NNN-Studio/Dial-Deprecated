//
//  MainController.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation

class MainController: Controller {
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?) {
        print("main click, double: \(isDoubleClick)")
    }
    
    func onRotation(_ rotation: Device.Rotation, _ buttonState: Device.ButtonState, interval: TimeInterval?) {
        print("main rotation")
    }
    
}
