//
//  Data.swift
//  Dial
//
//  Created by KrLite on 2023/10/27.
//

import Foundation
import LaunchAtLogin
import AppKit

enum DialMode: Int, CaseIterable {
    
    case scroll = 0x0
    case playback = 0x1
    case mission = 0x2
    case luminance = 0x3
    
    case custom1 = 0xF1
    case custom2 = 0xF2
    case custom3 = 0xF3
    case custom4 = 0xF4
    case custom5 = 0xF5
    case custom6 = 0xF6
    case custom7 = 0xF7
    case custom8 = 0xF8
    
    var icon: NSImage {
        switch self {
        case .scroll:
            DialMode.createIcon("chevron.up.chevron.down")!
        case .playback:
            DialMode.createIcon("play")!
        case .mission:
            DialMode.createIcon("command")!
        case .luminance:
            DialMode.createIcon("sun.max")!
            
        case .custom1:
            DialMode.createIcon("1.lane")!
        case .custom2:
            DialMode.createIcon("2.lane")!
        case .custom3:
            DialMode.createIcon("3.lane")!
        case .custom4:
            DialMode.createIcon("4.lane")!
        case .custom5:
            DialMode.createIcon("5.lane")!
        case .custom6:
            DialMode.createIcon("6.lane")!
        case .custom7:
            DialMode.createIcon("7.lane")!
        case .custom8:
            DialMode.createIcon("8.lane")!
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
            
        case .custom1:
            "1.circle.fill"
        case .custom2:
            "2.circle.fill"
        case .custom3:
            "3.circle.fill"
        case .custom4:
            "4.circle.fill"
        case .custom5:
            "5.circle.fill"
        case .custom6:
            "6.circle.fill"
        case .custom7:
            "7.circle.fill"
        case .custom8:
            "8.circle.fill"
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
        Key.dialMode.register(DialMode.scroll.rawValue)
        Key.haptics.register(true)
        Key.sensitivity.register(Sensitivity.natural.rawValue)
        Key.direction.register(Direction.clockwise.rawValue)
        Key.modeList.register([DialMode.scroll, DialMode.mission, DialMode.playback, DialMode.luminance])
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
            return DialMode(rawValue: value % maxRawValue)
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
