//
//  MainController.swift
//  Dial
//
//  Created by KrLite on 2023/10/28.
//

import Foundation

class MainController: Controller {
    
    func onDown() {
        AppDelegate.instance?.showDialWindow()
    }
    
    func onUp() {
        AppDelegate.instance?.hideDialWindow()
    }
    
    func onRotate(_ rotation: Dial.Rotation, _ direction: Int) {
        
    }
    
}
