//
//  Localization.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation

protocol Localizable: Codable {
    
    /// A name. Should be something like `This is a name`.
    var localizedName: String { get }
    
    /// A title. Should be something like `This is a Title with More Words Capitalized`. Defaults to `name`,
    var localizedTitle: String { get }
    
    /// A badge. Should be something like `this is a badge with all non-capital letters`. Defaults to `name`,
    var localizedBadge: String { get }
    
}

extension Localizable {
    
    var localizedTitle: String {
        localizedName
    }
    
    var localizedBadge: String {
        localizedName
    }
    
}

enum Localization: Codable {
    
    case openSettings
    
    case quit
    
    enum General: Codable {
        
        case sensitivity
        
        case direction
        
        case haptics
        
        case startsWithMacOS
        
    }
    
}

extension Localization: Localizable {
    
    var localizedName: String {
        switch self {
        case .openSettings:
            NSLocalizedString("OpenSettings.Name", value:"Open settings", comment: "open settings")
        case .quit:
            NSLocalizedString("Quit.Name", value:"Quit", comment: "quit")
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .openSettings:
            NSLocalizedString("OpenSettings.Title", value:"Open Settings", comment: "open settings")
        case .quit:
            NSLocalizedString("Quit.Title", value:"Quit", comment: "quit")
        }
    }
    
}

extension Localization.General: Localizable {
    
    var localizedName: String {
        switch self {
        case .sensitivity:
            NSLocalizedString("General/Sensitivity.Name", value: "Sensitivity", comment: "sensitivity")
        case .direction:
            NSLocalizedString("General/Direction.Name", value: "Direction", comment: "direction")
        case .haptics:
            NSLocalizedString("General/Haptics.Name", value: "Haptic feedback", comment: "haptics")
        case .startsWithMacOS:
            NSLocalizedString("General/StartsWithMacOS.Name", value: "Starts with macOS", comment: "starts with macOS")
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .sensitivity:
            NSLocalizedString("General/Sensitivity.Title", value: "Sensitivity", comment: "sensitivity")
        case .direction:
            NSLocalizedString("General/Direction.Title", value: "Direction", comment: "direction")
        case .haptics:
            NSLocalizedString("General/Haptics.Title", value: "Haptic Feedback", comment: "haptics")
        case .startsWithMacOS:
            NSLocalizedString("General/StartsWithMacOS.Title", value: "Starts with macOS", comment: "starts with macOS")
        }
    }
    
}
