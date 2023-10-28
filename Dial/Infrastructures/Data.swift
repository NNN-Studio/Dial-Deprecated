//
//  Data.swift
//  Dial
//
//  Created by KrLite on 2023/10/27.
//

import Foundation
import LaunchAtLogin

enum DialMode: Int {
    
    case scroll = 0
    
    case playback = 1
    
}

enum Sensitivity: Int {
    
    case low = 16
    
    case natural = 32
    
    case high = 64
    
    case superHigh = 128
    
    case extreme = 360
    
}

enum Direction: Int {
    
    /// Clockwise to scroll down.
    case clockwise = 1
    
    /// Counterclockwise to scroll down.
    case counterclockwise = -1
    
}

struct Data {
    
    enum Key: String {
        
        case dialMode = "DialMode"
        
        case haptics = "Haptics"
        
        case sensitivity = "Sensitivity"
        
        case direction = "Direction"
        
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
        
    }
    
    static func registerDefaults() {
        Key.dialMode.register(DialMode.scroll.rawValue)
        Key.haptics.register(true)
        Key.sensitivity.register(Sensitivity.natural.rawValue)
        Key.direction.register(Direction.clockwise.rawValue)
    }
    
    static var startsWithMacOS: Bool {
        get {
            LaunchAtLogin.isEnabled
        }
        
        set(flag) {
            LaunchAtLogin.isEnabled = flag
        }
    }
    
    static var dialMode: DialMode {
        get {
            DialMode(rawValue: Key.dialMode.integer()) ?? .scroll
        }
        
        set(dialMode) {
            Key.dialMode.set(dialMode.rawValue)
        }
    }
    
    static var haptics: Bool {
        get {
            Key.haptics.bool()
        }
        
        set(flag) {
            Key.haptics.set(flag)
        }
    }
    
    static var sensitivity: Sensitivity {
        get {
            Sensitivity(rawValue: Key.sensitivity.integer()) ?? .natural
        }
        
        set(sensitivity) {
            Key.sensitivity.set(sensitivity.rawValue)
        }
    }
    
    static var direction: Direction {
        get {
            Direction(rawValue: Key.direction.integer()) ?? .clockwise
        }
        
        set(direction) {
            Key.direction.set(direction.rawValue)
        }
    }
    
}
