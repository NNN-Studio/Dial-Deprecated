//
//  Controllers.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import Defaults

struct Controllers {
    
    static let defaultControllers: [Controller] = [
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
        Defaults[.activatedControllerIds].map( { fetch($0)! })
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
        
        if (index < defaultControllers.count) {
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
        if (activated) {
            Defaults[.activatedControllerIds].append(id)
        } else {
            if let i = Defaults[.activatedControllerIds].firstIndex(of: id) {
                Defaults[.activatedControllerIds].remove(at: i)
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
                && fetchAt < Defaults[.activatedControllerIds].count && insertAt <= Defaults[.activatedControllerIds].count
        else { return }
        
        let instance = Defaults[.activatedControllerIds].remove(at: fetchAt)
        Defaults[.activatedControllerIds].insert(instance, at: insertAt)
    }
    
}
