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
                .map { ShortcutsController(settings: $0) }
        }
        
        set {
            Defaults[.shortcutsControllerSettings] = Bag(newValue.map { $0.settings })
        }
    }
    
    static var activatedControllers: [Controller] {
        get {
            Defaults[.activatedControllerIDs]
                .compactMap { fetch($0) }
        }
        
        set {
            Defaults[.activatedControllerIDs] = newValue.map { $0.id }
        }
    }
    
    static var currentController: Controller {
        get {
            fetch(Defaults[.currentControllerID]) ?? defaultControllers[0]
        }
        
        set {
            Defaults[.currentControllerID] = newValue.id
        }
    }
    
    static func cycleThroughControllers(_ sign: Int = 1, wrap: Bool = true) {
        guard sign != 0 else { return }
        guard let index = activatedControllers.firstIndex(where: { $0.id == currentController.id }) else { return }
        
        let cycledIndex = index + sign.signum()
        let max = activatedControllers.count
        let inRange = NSRange(location: 0, length: activatedControllers.count).contains(cycledIndex)
        
        if wrap || inRange {
            currentController = activatedControllers[cycledIndex % max]
        }
    }
    
    static func indexOf(_ controller: Controller) -> Int? {
        if let defaultController = controller as? DefaultController {
            return defaultControllers
                .firstIndex(where: { $0.id == controller.id })
        }
        
        if let shortcutsController = controller as? ShortcutsController {
            return shortcutsControllers
                .firstIndex(where: { $0.id == controller.id })
                .map { $0 + defaultControllers.count }
        }
        
        return nil
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
    
    static func append() {
        shortcutsControllers.append(ShortcutsController(settings: ShortcutsController.Settings()))
    }
    
    static func remove(_ controller: Controller) {
        guard let shortcutsController = controller as? ShortcutsController else { return }
        if let index = shortcutsControllers.firstIndex(of: shortcutsController) {
            shortcutsControllers.remove(at: index)
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
            Defaults[.activatedControllerIDs].append(controller.id)
        } else {
            if let i = Defaults[.activatedControllerIDs].firstIndex(of: controller.id) {
                Defaults[.activatedControllerIDs].remove(at: i)
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
