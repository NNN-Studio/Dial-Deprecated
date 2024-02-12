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
    
    static let sensitivity = Key<Sensitivity>("sensitivity", default: .natural)
    
    static let autoHidesIconEnabled = Key<Bool>("autoHidesIconEnabled", default: false)
    
    
    
    static let shortcutsControllerSettings = Key<Bag<ShortcutsController.Settings>>("shortcutsControllerSettings", default: Bag([]))
    
    static let activatedControllerIDs = Key<[ControllerID]>(
        "activatedControllerIDs",
        default: [
            .default(.scroll),
            .default(.playback),
            .default(.mission),
            .default(.brightness)
        ]
    )
    
    static let currentControllerID = Key<ControllerID>("currentControllerID", default: .default(.scroll))
    
    
    
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
