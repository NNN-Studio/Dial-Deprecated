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
    
    let task = Task { @MainActor in
        for await value in observationTrackingStream({ SettingsWindowController.shared.pressedKey }) {
            print(100)
        }
    }
    
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
    
}
