//
//  Input.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation
import AppKit

struct Input {
    
    static let keyReturn: Int32 = 0x24
    
    static let keyTab: Int32 = 0x30
    
    static let keyEscape: Int32 = 0x35
    
    static let keyLeftArrow: Int32 = 0x7b
    
    static let keyRightArrow: Int32 = 0x7c
    
    static let keyDownArrow: Int32 = 0x7d
    
    static let keyUpArrow: Int32 = 0x7e
    
    static let keyVolumeUp: Int32 = NX_KEYTYPE_SOUND_UP
    
    static let keyVolumeDown: Int32 = NX_KEYTYPE_SOUND_DOWN
    
    static let keyPlay: Int32 = NX_KEYTYPE_PLAY
    
    static let keyMute: Int32 = NX_KEYTYPE_MUTE
    
}

extension Input {
    
    static func postMouse(_ button: CGMouseButton, buttonState action: Device.ButtonState) {
        let mouseLocation = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        
        let translatedMouseLocation = NSPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
        var mouseType: CGEventType?
        
        switch button {
        case .left:
            mouseType = action == .pressed ? .leftMouseDown : .leftMouseUp
            break
        case .right:
            mouseType = action == .pressed ? .rightMouseDown : .rightMouseUp
            break
        case .center:
            mouseType = action == .pressed ? .otherMouseDown : .otherMouseUp
            break
        @unknown default:
            break
        }
        
        if let mouseType {
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: mouseType,
                mouseCursorPosition: translatedMouseLocation,
                mouseButton: button
            )
            
            event?.post(tap: .cghidEventTap)
        }
    }
    
    // https://stackoverflow.com/a/55854051
    static func postAuxKeys(_ keys: [Int32], modifiers: [NSEvent.ModifierFlags] = [], _repeat: Int = 1) {
        func doKey(_ key: Int32, down: Bool) {
            var rawFlags: UInt = (down ? 0xa00 : 0xb00);
            
            for modifier in modifiers {
                rawFlags |= modifier.rawValue
            }
            
            let flags = NSEvent.ModifierFlags(rawValue: rawFlags)
            
            let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))
            
            let ev = NSEvent.otherEvent(
                with: NSEvent.EventType.systemDefined,
                location: NSPoint(x:0,y:0),
                modifierFlags: flags,
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: 8,
                data1: data1,
                data2: -1
            )
            
            let cev = ev?.cgEvent
            cev?.post(tap: CGEventTapLocation.cghidEventTap)
        }
        
        for key in keys {
            for _ in 0..<_repeat {
                doKey(key, down: true)
                doKey(key, down: false)
            }
        }
    }
    
    static func postKeys(_ keys: [Int32], modifiers: [NSEvent.ModifierFlags] = [], _repeat: Int = 1) {
        func doKey(_ key: Int32, down: Bool) {
            guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
                print("Failed to create event source")
                return
            }
            
            let ev = CGEvent(
                keyboardEventSource: eventSource,
                virtualKey: CGKeyCode(key),
                keyDown: down
            )
            ev?.flags = CGEventFlags(rawValue: (modifiers.reduce(0) { $0 | UInt64($1.rawValue) }))
            ev?.post(tap: .cghidEventTap)
        }
        
        for key in keys {
            for _ in 0..<_repeat {
                doKey(key, down: true)
                doKey(key, down: false)
            }
        }
    }
    
}
