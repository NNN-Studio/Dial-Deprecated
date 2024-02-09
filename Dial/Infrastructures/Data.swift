//
//  Data.swift
//  Dial
//
//  Created by KrLite on 2023/10/27.
//

import Foundation
import LaunchAtLogin
import AppKit

enum DefaultDialMode: Int, CaseIterable {
    
    case scroll = 0x0
    
    case playback = 0x1
    
    case mission = 0x2
    
    case luminance = 0x3
    
    var icon: NSImage {
        switch self {
        case .scroll:
            DefaultDialMode.createIcon("chevron.up.chevron.down")!
        case .playback:
            DefaultDialMode.createIcon("play")!
        case .mission:
            DefaultDialMode.createIcon("command")!
        case .luminance:
            DefaultDialMode.createIcon("sun.max")!
        }
    }
    
    var modeIconName: String {
        switch self {
        case .scroll:
            "arrow.up.and.down.circle.fill"
        case .playback:
            "play.circle.fill"
        case .mission:
            "command.circle.fill"
        case .luminance:
            "sun.max.circle.fill"
        }
    }
    
    private static func createIcon(_ systemName: String) -> NSImage? {
        NSImage(systemSymbolName: systemName, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 20, weight: .medium))
    }
    
}

struct Data {
    
    enum Key: String {
        
        case dialMode = "DialMode"
        
        func register(
            _ value: Any
        ) {
            UserDefaults.standard.register(defaults: [rawValue: value])
        }
        
        func set(
            _ value: Any?
        ) {
            UserDefaults.standard.set(value, forKey: rawValue)
        }
        
        func bool() -> Bool {
            UserDefaults.standard.bool(forKey: rawValue)
        }
        
        func integer() -> Int {
            UserDefaults.standard.integer(forKey: rawValue)
        }
        
        func float() -> Float {
            UserDefaults.standard.float(forKey: rawValue)
        }
        
    }
    
    static var dialMode: DefaultDialMode {
        get {
            DefaultDialMode(rawValue: Key.dialMode.integer()) ?? .scroll
        }
        
        set(dialMode) {
            Key.dialMode.set(dialMode.rawValue)
        }
    }
    
    static func getCycledDialMode(_ signum: Int, wrap: Bool = true) -> DefaultDialMode? {
        let value = dialMode.rawValue + signum.signum()
        let maxRawValue = DefaultDialMode.allCases.count
        let inRange = NSRange(location: 0, length: maxRawValue).contains(value)
        
        if wrap || inRange {
            return DefaultDialMode(rawValue: value % maxRawValue)
        }
        
        return nil
    }
}
