//
//  SubmenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import Foundation
import Defaults

@objc protocol DialSubmenuDelegate: AnyObject {
    
    @objc func setSensitivity(_ sender: Any?)
    
    @objc func setDirection(_ sender: Any?)
    
}

struct SubmenuItems {
    
    let delegate: DialSubmenuDelegate
    
    var sensitivityOptions: [MenuOptionItem<Sensitivity>] {
        let options = [
            MenuOptionItem<Sensitivity>(Sensitivity.low.localizedName, option: .low),
            MenuOptionItem<Sensitivity>(Sensitivity.medium.localizedName, option: .medium),
            MenuOptionItem<Sensitivity>(Sensitivity.natural.localizedName, option: .natural),
            MenuOptionItem<Sensitivity>(Sensitivity.high.localizedName, option: .high),
            MenuOptionItem<Sensitivity>(Sensitivity.extreme.localizedName, option: .extreme)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setSensitivity(_:))
            
            Task { @MainActor in
                for await value in Defaults.updates(.sensitivity) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
    var directionOptions: [MenuOptionItem<Direction>] {
        let options = [
            MenuOptionItem<Direction>(Direction.clockwise.localizedName, option: .clockwise),
            MenuOptionItem<Direction>(Direction.counterclockwise.localizedName, option: .counterclockwise)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setDirection(_:))
            option.image = option.option.representingSymbol.raw
            
            Task { @MainActor in
                for await value in Defaults.updates(.direction) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
}
