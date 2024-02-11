//
//  SettingsWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {
    
    static let shared: SettingsWindowController = {
        return NSStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateController(withIdentifier: "SettingsWindowController") as! SettingsWindowController
    }()
    
    override func windowDidLoad() {
        self.window?.level = .mainMenu
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode, event.modifierFlags)
        let keyCode = Int32(event.keyCode)
        
        if event.modifierFlags.contains(.command) && (Input.keyQ.conformsTo(keyCode) || Input.keyW.conformsTo(keyCode)) {
            // Closes with Command+W / Command+W
            close()
        }
    }

}
