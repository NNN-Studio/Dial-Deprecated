//
//  EditableTextField.swift
//  Dial
//
//  Created by KrLite on 2024/2/16.
//

import Foundation
import AppKit

// https://blog.kulman.sk/making-copy-paste-work-with-nstextfield
class EditableTextField: NSTextField {
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == .keyDown {
            let flags = NSEvent.ModifierFlags(rawValue: event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue)
            let key = Input(rawValue: Int32(event.keyCode))
            
            if flags == [] {
                switch key {
                case .keyEscape:
                    AppDelegate.loseFocus()
                    return true
                default:
                    break
                }
            }
            
            if flags == .command {
                switch key {
                case .keyX:
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case .keyC:
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case .keyV:
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case .keyZ:
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case .keyA:
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            }
            
            if flags == .command.union(.shift) {
                switch key {
                case .keyZ:
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                default:
                    break
                }
            }
        }
        
        if SettingsWindowController.shared.performKeyEquivalent(with: event) {
            AppDelegate.loseFocus() // Save session
            return true
        }
        
        return super.performKeyEquivalent(with: event)
    }
    
}
