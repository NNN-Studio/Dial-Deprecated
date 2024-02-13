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

struct RotationTypeMenuItems {
    
    let delegate: DialRotationTypeMenuDelegate
    
    var rotationTypeOptions: [MenuOptionItem<Dial.Rotation.RawType>] {
        let options: [MenuOptionItem<Dial.Rotation.RawType>] = [
            .init(Dial.Rotation.RawType.continuous.localizedName, option: .continuous),
            .init(Dial.Rotation.RawType.stepping.localizedName, option: .stepping)
        ]
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setRotationType(_:))
            option.image = option.option.representingSymbol.raw
            
            Task { @MainActor in
                for await _ in Defaults.updates(.shortcutsControllerSettings) {
                    for controller in Controllers.shortcutsControllers {
                        if controller.id == Controllers.selectedController.id {
                            option.flag = option.option == controller.settings.rotationType
                        }
                    }
                }
            }
        }
        
        return options
    }
    
}
