//
//  ShortcutController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import Defaults

class ShortcutController: Controller {
    
    struct Settings {
        
        var haptics: Bool
        
        var plysicalDirection: Bool
        
        var alternativeDirection: Bool
        
        var rotationMapper: (Dial.Rotation) -> Direction?
        
        var shortcuts: (rotation: [Direction: ShortcutArray], single: ShortcutArray, double: ShortcutArray)
        
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
        guard let mapped = settings.rotationMapper(rotation) else { return }
        
        var direction = settings.plysicalDirection ? mapped.physical : mapped
        if (settings.alternativeDirection) { direction = direction.negate }
        
        settings.shortcuts.rotation[direction]?.post()
    }
    
}
