//
//  SettingsWindow.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {
    
    static let shared: SettingsWindowController? = {
        return NSStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateController(withIdentifier: "SettingsWindowController") as? SettingsWindowController
    }()
    
    var pressedKey: Input = .unknown
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.level = .mainMenu
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSRunningApplication.current.activate()
    }
    
    override func keyDown(with event: NSEvent) {
        let keyCode = Int32(event.keyCode)
        let performed = performKeyEquivalent(with: event)
        
        if let key = Input(rawValue: keyCode), !performed {
            pressedKey = key
        }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == .keyDown {
            let flags = NSEvent.ModifierFlags(rawValue: event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue)
            let key = Input(rawValue: Int32(event.keyCode))
            
            if flags == .command {
                switch key {
                case .keyQ:
                    AppDelegate.quitApp()
                    return true
                case .keyW:
                    close()
                    return true                    
                default:
                    break
                }
            }
        }
        
        return super.performKeyEquivalent(with: event)
    }

}
