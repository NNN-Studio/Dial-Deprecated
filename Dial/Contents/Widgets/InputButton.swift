//
//  InputButton.swift
//  Dial
//
//  Created by KrLite on 2024/2/14.
//

import Cocoa

class InputButton: NSButton {
    
    var listening = false
    
    var keys: [Input] = []
    
    override func mouseDown(with event: NSEvent) {
        print("down")
        listening = true
    }
    
    override func mouseUp(with event: NSEvent) {
        print("up")
        listening = false
        sendAction(action, to: target)
        print(keys)
    }
    
    override func keyDown(with event: NSEvent) {
        print(1)
        let key = Input(rawValue: Int32(event.keyCode))
        if let key, key != .unknown { keys.append(key) }
    }
    
}
