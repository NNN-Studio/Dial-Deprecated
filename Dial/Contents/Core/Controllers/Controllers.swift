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
    
    @available(*, deprecated)
    static func fetch(menuIndex index: Int) -> Controller? {
        guard index >= 0 else { return nil }
        
        if index < defaultControllers.count {
            return defaultControllers[index]
        } else {
            return shortcutsControllers[index - defaultControllers.count]
        }
    }
    
    static func append() -> ShortcutsController {
        let controller = ShortcutsController(settings: ShortcutsController.Settings())
        shortcutsControllers.append(controller)
        return controller
    }
    
    static func remove(_ controller: Controller) {
        guard let shortcutsController = controller as? ShortcutsController else { return }
        
        if let index = shortcutsControllers.firstIndex(of: shortcutsController) {
            shortcutsControllers.remove(at: index)
            activatedControllers = activatedControllers // Trigger refresh
        }
        
        if shortcutsController.id == currentController.id {
            currentController = activatedControllers.first!
        }
    }
    
    static func modify(
        _ controller: Controller,
        operation: @escaping (ShortcutsController) -> ShortcutsController
    ) {
        guard let shortcutsController = controller as? ShortcutsController else { return }
        
        if let index = shortcutsControllers.firstIndex(of: shortcutsController) {
            shortcutsControllers[index] = operation(shortcutsController)
        }
    }
    
    static func toggle(_ activated: Bool, controller: Controller) {
        if activated {
            if !activatedControllers.contains(where: { $0.id == controller.id }) {
                activatedControllers.append(controller)
            }
        } else {
            if let index = activatedControllers.firstIndex(where: { $0.id == controller.id }) {
                activatedControllers.remove(at: index)
                
                if currentController.id == controller.id {
                    currentController = activatedControllers.first!
                }
            }
        }
    }
    
    @available(*, deprecated)
    static func toggle(_ activated: Bool, menuIndex index: Int) {
        if let controller = fetch(menuIndex: index) {
            toggle(activated, controller: controller)
        }
    }
    
    static func reorder(fetchAt: Int, insertAt: Int) {
        guard
            fetchAt != insertAt
                && fetchAt >= 0 && insertAt >= 0
                && fetchAt < Defaults[.activatedControllerIDs].count && insertAt <= Defaults[.activatedControllerIDs].count
        else { return }
        
        let instance = Defaults[.activatedControllerIDs].remove(at: fetchAt)
        Defaults[.activatedControllerIDs].insert(instance, at: insertAt)
    }
    
}
