//
//  Data.swift
//  Dial
//
//  Created by KrLite on 2023/10/27.
//

import Foundation

enum DialMode: Int {
    
    case scroll = 0
    
    case zoom = 1
    
    case playback = 2
    
}

enum Direction: Int {
    
    /// Clockwise to scroll down.
    case clockwise = 0
    
    /// Anticlockwise to scroll down.
    case anticlockwise = 1
    
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
        
        func array() -> [Any]? {
            UserDefaults.standard.array(forKey: rawValue)
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
        Key.sensitivity.register(36)
        Key.direction.register(Direction.clockwise.rawValue)
    }
    
}
