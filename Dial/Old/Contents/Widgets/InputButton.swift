//
//  InputButton.swift
//  Dial
//
//  Created by KrLite on 2024/2/14.
//

import Cocoa

class InputButton: NSButton {
    
    static let fontSize = (label: 10.0, keys: 13.0)
    
    var listening = false
    
    var keys: [Input] = []
    
    var hasKeys: Bool {
        !keys.isEmpty
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        showsBorderOnlyWhileMouseInside = true
        
        Task { @MainActor in
            for await value in observationTrackingStream({ SettingsWindowController.shared!.pressedKey }) {
                if value != .unknown && listening {
                    // Remove the key if present before adding it again
                    keys.removeAll(where: { $0 == value })
                    
                    keys.append(value)
                    updateTitle()
                }
            }
        }
        
        updateTitle()
    }
    
    override func mouseDown(with event: NSEvent) {
        AppDelegate.loseFocus()
        keys = []
        listening = true
        updateTitle()
        
        animator().alphaValue = 0.75
    }
    
    override func mouseUp(with event: NSEvent) {
        listening = false
        sendAction(action, to: target)
        updateTitle()
        
        animator().alphaValue = 1
    }
    
    func updateTitle() {
        if hasKeys {
            title = keys.map({ $0.name }).joined(separator: " ")
            
            if let font {
                self.font = NSFont(name: font.fontName, size: InputButton.fontSize.keys)
            }
        } else {
            if listening {
                title = Localization.Controllers.Shortcuts.cancellable.localizedName
            } else {
                title = Localization.Controllers.Shortcuts.idle.localizedName
            }
            
            if let font {
                self.font = NSFont(name: font.fontName, size: InputButton.fontSize.label)
            }
        }
    }
    
}
