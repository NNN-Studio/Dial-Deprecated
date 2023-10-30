//
//  MainController.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation

class MainController: Controller {
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.instance?.buzz()
            AppDelegate.instance?.showDialWindow()
        }
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.instance?.hideDialWindow()
        }
    }
    
    func onRotation(_ rotation: Device.Rotation, last: TimeInterval?, buttonState: Device.ButtonState) {
        var step: Int
        
        switch rotation {
        case .clockwise(let _repeat):
            step = _repeat
        case .counterclockwise(let _repeat):
            step = -_repeat
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            AppDelegate.instance?.dial.statusBarController.setDialModeAndUpdate(Data.getCycledDialMode(-step.signum(), wrap: false))
            AppDelegate.instance?.updateDialWindow()
        }
    }
    
}
