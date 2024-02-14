//
//  SettingsWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

@Observable class SettingsWindowController: NSWindowController {
    
    static let shared: SettingsWindowController = {
        return NSStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateController(withIdentifier: "SettingsWindowController") as! SettingsWindowController
    }()
    
    var pressedKey: Input = .unknown
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.level = .mainMenu
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    override func keyDown(with event: NSEvent) {
        let keyCode = Int32(event.keyCode)
        
        if let key = Input(rawValue: keyCode) {
            pressedKey = key
        }
        
        if event.modifierFlags.contains(.command) && (Input.keyQ.conformsTo(keyCode) || Input.keyW.conformsTo(keyCode)) {
            // Closes with Command+W / Command+W
            close()
        }
    }
    
    static func loseFocus() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }

}
