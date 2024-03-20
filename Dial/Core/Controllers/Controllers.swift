//
//  Controllers.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import Defaults

struct Controllers {
    
    static let defaultControllers: [DefaultController] = [
        ScrollController(),
        PlaybackController(),
        MissionController(),
        BrightnessController()
    ]
    
    static var shortcutsControllers: [ShortcutsController] {
        get {
            Defaults[.shortcutsControllerSettings]
                .map { .init(settings: $0) }
        }
        
        set {
            Defaults[.shortcutsControllerSettings] = Bag(newValue.map { $0.settings })
        }
    }
    
    static var activatedControllers: [Controller] {
        get {
            if Defaults[.activatedControllerIDs].isEmpty {
                Defaults.reset(.activatedControllerIDs)
            }
            
            if Defaults[.activatedControllerIDs].count > Defaults[.maxControllerCount] {
                Defaults[.activatedControllerIDs].removeLast(Defaults[.activatedControllerIDs].count - Defaults[.maxControllerCount])
            }
            
            return Defaults[.activatedControllerIDs].compactMap { fetch($0) }
        }
        
        set {
            guard !newValue.isEmpty else { return }
            guard newValue.count <= Defaults[.maxControllerCount] else { return }
            
            Defaults[.activatedControllerIDs] = newValue.map { $0.id }
        }
    }
    
    static var currentController: Controller {
        get {
            if
                let controller = fetch(Defaults[.currentControllerID]),
                Defaults[.activatedControllerIDs].contains(Defaults[.currentControllerID])
            {
                return controller
            } else {
                let controller = activatedControllers.first!
                Defaults[.currentControllerID] = controller.id
                return controller
            }
        }
        
        set {
            Defaults[.currentControllerID] = newValue.id
        }
    }
    
    static var selectedController: Controller {
        get {
            if let controller = fetch(Defaults[.selectedControllerID]) {
                return controller
            }
            
            else {
                let controller = defaultControllers.first!
                Defaults[.selectedControllerID] = controller.id
                return controller
            }
        }
        
        set {
            Defaults[.selectedControllerID] = newValue.id
        }
    }
    
    static var selectedSettings: ShortcutsController.Settings? {
        get {
            (selectedController as? ShortcutsController)?.settings
        }
        
        set {
            if let newValue {
                for (index, settings) in Defaults[.shortcutsControllerSettings].enumerated() {
                    if settings.id == newValue.id {
                        shortcutsControllers[index] = .init(settings: newValue)
                    }
                }
            }
        }
    }
    
    static func cycleThroughControllers(_ sign: Int = 1, wrap: Bool = true) {
        guard sign != 0 else { return }
        guard let index = activatedControllers.firstIndex(where: { $0.id == currentController.id }) else { return }
        
        let cycledIndex = index + sign.signum()
        let count = activatedControllers.count
        let inRange = NSRange(location: 0, length: count).contains(cycledIndex)
        
        if wrap || inRange {
            currentController = activatedControllers[(cycledIndex + count) % count]
            DispatchQueue.main.async {
                AppDelegate.shared?.dial.device.buzz()
            }
        }
    }
    
    static func indexOf(_ controller: Controller) -> Int? {
        if controller.isDefaultController {
            return defaultControllers
                .firstIndex(where: { $0.id == controller.id })
        } else {
            return shortcutsControllers
                .firstIndex(where: { $0.id == controller.id })
                .map { $0 + defaultControllers.count }
        }
    }
    
    static func activatedIndexOf(_ controller: Controller) -> Int? {
        activatedControllers.firstIndex(where: { $0.id == controller.id })
    }
    
    static func fetch(_ id: ControllerID) -> Controller? {
        switch id {
        case .id(let uUID):
            if let settings = Defaults[.shortcutsControllerSettings].filter({ $0.id == uUID }).first {
                ShortcutsController(settings: settings)
            } else { nil }
        case .default(_):
            defaultControllers.filter { $0.id == id }.first
        }
    }
    
}
