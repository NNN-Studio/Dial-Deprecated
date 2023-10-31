//
//  Data.swift
//  Dial
//
//  Created by KrLite on 2023/10/27.
//

import Foundation
import LaunchAtLogin

enum DialMode: Int, CaseIterable {
    
    case scroll = 0
    
    case playback = 1
    
    case mission = 2
    
}

/// Decides how much steps per circle the dial is divided into.
enum Sensitivity: CGFloat {
    
    case low = 6
    
    case medium = 10
    
    case natural = 18
    
    case high = 36
    
    case extreme = 90
    
}

enum Direction: Int {
    
    case clockwise = 1
    
    /// Basically, the rotation of dial is inverted.
    case counterclockwise = -1
    
    var negate: Direction {
        switch self {
        case .clockwise:
            .counterclockwise
        case .counterclockwise:
            .clockwise
        }
    }
    
    static func *(lhs: Direction, rhs: Direction) -> Direction {
        lhs == rhs ? lhs : lhs.negate
    }
    
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
        
        func float() -> Float {
            UserDefaults.standard.float(forKey: rawValue)
        }
        
    }
    
    static func registerDefaults() {
        Key.dialMode.register(DialMode.scroll.rawValue)
        Key.haptics.register(true)
        Key.sensitivity.register(Sensitivity.natural.rawValue)
        Key.direction.register(Direction.clockwise.rawValue)
    }
    
    static let rotationThresholdDegrees: UInt = 10
    
    static var rotationGap: Int {
        Int(360 / sensitivity.rawValue)
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
    
    static func getCycledDialMode(_ signum: Int, wrap: Bool = true) -> DialMode? {
        let value = dialMode.rawValue + signum.signum()
        let maxRawValue = DialMode.allCases.count
        let inRange = NSRange(location: 0, length: maxRawValue).contains(value)
        
        if wrap || inRange {
            return DialMode(rawValue: value % maxRawValue) ?? .scroll
        }
        
        return nil
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
            Sensitivity(rawValue: CGFloat(Key.sensitivity.float())) ?? .natural
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
