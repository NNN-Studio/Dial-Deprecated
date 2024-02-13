//
//  ShortcutsController.swift
//  Dial
//
//  Created by KrLite on 2024/2/10.
//

import Foundation
import Defaults
import SFSafeSymbols

class ShortcutsController: Controller {
    
    struct Settings: SymbolRepresentable, Codable, Defaults.Serializable {
        
        var id: UUID
        
        var index: Int {
            Defaults[.shortcutsControllerSettings].firstIndex(where: { $0.id == id })!
        }
        
        
        
        var name: String?
        
        var representingSymbol: SFSymbol
        
        
        
        var haptics: Bool
        
        var physicalDirection: Bool
        
        var alternativeDirection: Bool
        
        
        
        var rotationType: Dial.Rotation.RawType
        
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
            name: String? = nil,
            representingSymbol: SFSymbol = .fallback,
            haptics: Bool = true,
            physicalDirection: Bool = false, alternativeDirection: Bool = false,
            rotationType: Dial.Rotation.RawType = .continuous, shortcuts: Shortcuts = Shortcuts()
        ) {
            self.id = UUID()
            
            self.name = name
            self.representingSymbol = representingSymbol
            
            self.haptics = haptics
            self.physicalDirection = physicalDirection
            self.alternativeDirection = alternativeDirection
            
            self.rotationType = rotationType
            self.shortcuts = shortcuts
        }
        
    }
    
    var settings: Settings
    
    var id: ControllerID {
        .id(settings.id)
    }
    
    var name: String {
        settings.name ?? NSLocalizedString(
            "Controllers/Shortcuts/Fallback/Name",
            value: "Controller \(settings.index + 1)",
            comment: "shortcuts controller fallback name"
        )
    }
    
    var representingSymbol: SFSymbol {
        settings.representingSymbol
    }
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        if isDoubleClick {
            settings.shortcuts.double.post()
        } else {
            settings.shortcuts.single.post()
        }
        
        if settings.haptics {
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
        
        if settings.alternativeDirection { direction = direction.negate }
        if settings.physicalDirection { direction = direction.physical }
        
        settings.shortcuts.rotation[direction]?.post()
    }
    
}

extension ShortcutsController: Equatable {
    
    static func == (lhs: ShortcutsController, rhs: ShortcutsController) -> Bool {
        lhs.id == rhs.id
    }
    
}
