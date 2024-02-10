//
//  PreferencesWindowController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController {
    
    static let shared: PreferencesWindowController = {
        return NSStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateController(withIdentifier: "Main") as! PreferencesWindowController
    }()

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.level = .mainMenu
        window?.center()
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode, event.modifierFlags)
        let keyCode = Int32(event.keyCode)
        
        if (event.modifierFlags.contains(.command) && (Input.keyQ.conforms(keyCode) || Input.keyW.conforms(keyCode))) {
            // Closes with Command+W / Command+W
            close()
        }
    }

}
