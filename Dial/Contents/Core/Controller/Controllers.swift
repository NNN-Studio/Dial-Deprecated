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
            Defaults[.shortcutsControllerSettings].map { ShortcutsController(settings: $0) }
        }
        
        set {
            Defaults[.shortcutsControllerSettings] = Bag(newValue.map { $0.settings })
        }
    }
    
    static var activatedControllers: [Controller] {
        Defaults[.activatedControllerIDs].map( { fetch($0)! })
    }
    
    static var currentController: Controller {
        fetch(Defaults[.currentControllerID])!
    }
    
    static func cycleThroughControllers(_ sign: Int = 1, wrap: Bool = true) {
        guard sign != 0 else { return }
        
        let index = activatedControllers.firstIndex(where: { $0.id == currentController.id })! + sign.signum()
        let max = activatedControllers.count
        let inRange = NSRange(location: 0, length: activatedControllers.count).contains(index)
        
        if wrap || inRange {
            Defaults[.currentControllerID] = activatedControllers[index % max].id
        }
    }
    
    static func indexOf(_ id: ControllerID) -> Int? {
        return defaultControllers.firstIndex(where: { $0.id == id }) ?? (shortcutsControllers.firstIndex(where: { $0.id == id }).map { $0 + defaultControllers.count })
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
    
    static func remove(at index: Int) {
        shortcutsControllers.remove(at: index)
    }
    
    static func modify(
        _ index: Int,
        operation: @escaping (ShortcutsController) -> ShortcutsController
    ) {
        guard index >= 0 && index < Defaults[.shortcutsControllerSettings].count else { return }
        
        let controller = shortcutsControllers[index]
        shortcutsControllers[index] = operation(controller)
    }
    
    static func toggle(_ activated: Bool, id: ControllerID) {
        if activated {
            Defaults[.activatedControllerIDs].append(id)
        } else {
            if let i = Defaults[.activatedControllerIDs].firstIndex(of: id) {
                Defaults[.activatedControllerIDs].remove(at: i)
            }
        }
    }
    
    static func toggle(_ activated: Bool, menuIndex index: Int) {
        if let id = fetch(menuIndex: index)?.id {
            toggle(activated, id: id)
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
