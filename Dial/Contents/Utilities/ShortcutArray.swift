//
//  ShortcutArray.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import AppKit

extension NSEvent.ModifierFlags: Codable {
    
    // Make it codable
    
}

struct ShortcutArray: Codable {
    
    var modifiers: [NSEvent.ModifierFlags]
    
    var keys: [Input]
    
    var display: String {
        keys.map { $0.name }.joined(separator: " ")
    }
    
    init(
        modifiers: [NSEvent.ModifierFlags] = [],
        keyCodes: [Int32]
    ) {
        self.init(modifiers: modifiers, keys: Input.fromKeyCodes(keyCodes))
    }
    
    init(
        modifiers: [NSEvent.ModifierFlags] = [],
        keys: [Input] = []
    ) {
        self.modifiers = modifiers
        self.keys = keys
    }
    
    func post() {
        Input.postKeys(keys, modifiers: modifiers)
    }
    
}
