//
//  ShortcutsController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import Defaults

class ShortcutsController: Controller {
    
    struct Settings: Codable, Defaults.Serializable {
        
        var haptics: Bool
        
        var physicalDirection: Bool
        
        var alternativeDirection: Bool
        
        var rotationType: Dial.Rotation.`Type`
        
        var shortcuts: Shortcuts
        
        struct Shortcuts: Codable {
            
            var rotation: [Direction: ShortcutArray]
            
            var single: ShortcutArray
            
            var double: ShortcutArray
            
            init(
                rotation: [Direction : ShortcutArray] = [.clockwise: ShortcutArray(), .counterclockwise: ShortcutArray()],
                single: ShortcutArray = ShortcutArray(),
                double: ShortcutArray = ShortcutArray()
            ) {
                self.rotation = rotation
                self.single = single
                self.double = double
            }
            
        }
        
        init(
            haptics: Bool = true,
            physicalDirection: Bool = false, alternativeDirection: Bool = false,
            rotationType: Dial.Rotation.`Type` = .continuous, shortcuts: Shortcuts = Shortcuts()
        ) {
            self.haptics = haptics
            self.physicalDirection = physicalDirection
            self.alternativeDirection = alternativeDirection
            self.rotationType = rotationType
            self.shortcuts = shortcuts
        }
        
    }
    
    var settings: Settings
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        if (isDoubleClick) {
            settings.shortcuts.double.post()
        } else {
            settings.shortcuts.single.post()
        }
        
        if (settings.haptics) {
            callback.device.buzz()
        }
    }
    
    func onRotation(
        rotation: Dial.Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        guard rotation.conformsTo(settings.rotationType) else { return }
        
        var direction = rotation.direction
        
        if (settings.alternativeDirection) { direction = direction.negate }
        if (settings.physicalDirection) { direction = direction.physical }
        
        settings.shortcuts.rotation[direction]?.post()
    }
    
}