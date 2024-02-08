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

/// Decides how much steps per circle the dial is divided into.
enum Sensitivity: CGFloat {
    
    case low = 5
    
    case medium = 7
    
    case natural = 10
    
    case high = 30
    
    case extreme = 45
    
    /// Decides how much steps per circle the dial is divided into in continuous rotation.
    var continuous: CGFloat {
        switch self {
        case .low:
            60
        case .medium:
            90
        case .natural:
            120
        case .high:
            240
        case .extreme:
            360
        }
    }
    
    var gap: (stepping: CGFloat, continuous: CGFloat) {
        (stepping: 360 / rawValue, continuous: 360 / self.continuous)
    }
    
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
    
    func negateIf(_ flag: Bool) -> Direction {
        flag ? negate : self
    }
    
    func multiply(_ another: Direction) -> Direction {
        switch another {
        case .clockwise:
            self
        case .counterclockwise:
            self.negate
        }
    }
    
}

struct Data {
    
    enum Key: String {
        
        case dialMode = "DialMode"
        
        case haptics = "Haptics"
        
        case sensitivity = "Sensitivity"
        
        case direction = "Direction"
        
        case modeList = "ModeList"
        
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
        Key.dialMode.register(DefaultDialMode.scroll.rawValue)
        Key.haptics.register(true)
        Key.sensitivity.register(Sensitivity.natural.rawValue)
        Key.direction.register(Direction.clockwise.rawValue)
        Key.modeList.register([DefaultDialMode.scroll, DefaultDialMode.mission, DefaultDialMode.playback, DefaultDialMode.luminance])
    }
    
    static let maxIconCount = 10
    
    static let rotationThresholdDegrees: UInt = 10
    
    static var startsWithMacOS: Bool {
        get {
            LaunchAtLogin.isEnabled
        }
        
        set(flag) {
            LaunchAtLogin.isEnabled = flag
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
