//
//  RotationTypeMenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/14.
//

import Foundation
import Defaults

@objc protocol DialRotationTypeMenuDelegate: AnyObject {
    
    @objc func setRotationType(_ sender: Any?)
    
}

class RotationTypeMenuItems {
    
    let delegate: DialRotationTypeMenuDelegate
    
    init(delegate: DialRotationTypeMenuDelegate) {
        self.delegate = delegate
        
        self.rotationTypeOptions = [
            .init(Rotation.RawType.continuous.localizedName, option: .continuous),
            .init(Rotation.RawType.stepping.localizedName, option: .stepping)
        ]
        
        initialize()
    }
    
    private func initialize() {
        for option in rotationTypeOptions {
            option.target = delegate
            option.action = #selector(delegate.setRotationType(_:))
            option.image = option.option.representingSymbol.image
        }
        if let rotationType = Controllers.selectedSettings?.rotationType {
            updateRotationTypeOptions(rotationType)
        }
    }
    
    var rotationTypeOptions: [MenuOptionItem<Rotation.RawType>]
    
}

extension RotationTypeMenuItems {
    
    func updateRotationTypeOptions(_ value: Rotation.RawType) {
        for option in rotationTypeOptions {
            option.flag = option.option == value
        }
    }
    
}
