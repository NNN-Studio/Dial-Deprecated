//
//  Defaults.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import Defaults
import LaunchAtLogin

extension Defaults.Keys {
    
    static let hapticsEnabled = Key<Bool>("hapticsEnabled", default: true)
    
    static let direction = Key<Direction>("direction", default: .clockwise)
    
    static let senstivity = Key<Sensitivity>("sensitivity", default: .natural)
    
    
    
    static let activatedControllerIndexes = Key<[Int]>("activatedControllerIndexes", default: [-1, -2, -3, -4])
    
    
    
    static let rotationThresholdDegrees = Key<UInt>("rotationThresholdDegrees", default: 10)
    
    static let maxIconCount = Key<Int>("maxIconCount", default: 10)
    
}

extension Defaults {
    
    static var launchAtLogin: Bool {
        get {
            LaunchAtLogin.isEnabled
        }
        
        set(flag) {
            LaunchAtLogin.isEnabled = flag
        }
    }
    
}
