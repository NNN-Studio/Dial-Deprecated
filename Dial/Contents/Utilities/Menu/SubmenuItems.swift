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
        let options: [MenuOptionItem<Sensitivity>] = [
            .init(Sensitivity.low.localizedName, option: .low),
            .init(Sensitivity.medium.localizedName, option: .medium),
            .init(Sensitivity.natural.localizedName, option: .natural),
            .init(Sensitivity.high.localizedName, option: .high),
            .init(Sensitivity.extreme.localizedName, option: .extreme)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setSensitivity(_:))
            option.image = option.option.representingSymbol.image
            
            Task { @MainActor in
                for await value in Defaults.updates(.sensitivity) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
    var directionOptions: [MenuOptionItem<Direction>] {
        let options: [MenuOptionItem<Direction>] = [
            .init(Direction.clockwise.localizedName, option: .clockwise),
            .init(Direction.counterclockwise.localizedName, option: .counterclockwise)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setDirection(_:))
            option.image = option.option.representingSymbol.image
            
            Task { @MainActor in
                for await value in Defaults.updates(.direction) {
                    option.flag = option.option == value
                }
            }
        }
        
        return options
    }
    
}
