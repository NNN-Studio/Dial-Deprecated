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

class SubmenuItems {
    
    let delegate: DialSubmenuDelegate
    
    init(delegate: DialSubmenuDelegate) {
        self.delegate = delegate
        
        self.sensitivityOptions = [
            .init(Sensitivity.low.localizedName, option: .low),
            .init(Sensitivity.medium.localizedName, option: .medium),
            .init(Sensitivity.natural.localizedName, option: .natural),
            .init(Sensitivity.high.localizedName, option: .high),
            .init(Sensitivity.extreme.localizedName, option: .extreme)
        ]
        self.directionOptions = [
            .init(Direction.clockwise.localizedName, option: .clockwise),
            .init(Direction.counterclockwise.localizedName, option: .counterclockwise)
        ]
        
        initialize()
    }
    
    private func initialize() {
        for option in sensitivityOptions {
            option.target = delegate
            option.action = #selector(delegate.setSensitivity(_:))
            option.image = option.option.representingSymbol.image
        }
        updateSensitivityOptions(Defaults[.sensitivity])
        
        for option in directionOptions {
            option.target = delegate
            option.action = #selector(delegate.setDirection(_:))
            option.image = option.option.representingSymbol.image
        }
        updateDirectionOptions(Defaults[.direction])
    }
    
    var sensitivityOptions: [MenuOptionItem<Sensitivity>]
    
    var directionOptions: [MenuOptionItem<Direction>]
    
}

extension SubmenuItems {
    
    func updateSensitivityOptions(_ value: Sensitivity) {
        for option in sensitivityOptions {
            option.flag = option.option == value
        }
    }
    
    func updateDirectionOptions(_ value: Direction) {
        for option in directionOptions {
            option.flag = option.option == value
        }
    }
    
}
