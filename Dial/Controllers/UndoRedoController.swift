//
//  UndoRedoController.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation

class UndoRedoController: Controller {
    
    func hapticsMode() -> Dial.HapticsMode {
        .buzz
    }
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?, buttonState: Dial.ButtonState) {
    }
    
}
