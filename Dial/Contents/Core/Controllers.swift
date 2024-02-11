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
        LuminanceController()
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
        Defaults[.activatedControllerIndexes]
            .filter(isValidIndex(_:))
            .map( { fetch($0)! })
    }
    
    static func isValidIndex(_ index: Int) -> Bool {
        (index >= 0 && index < Defaults[.shortcutsControllerSettings].count) || (index < 0 && abs(index) <= defaultControllers.count)
    }
    
    static func fetch(_ index: Int) -> Controller? {
        // 0, 1, ...
        if (index >= 0 && index < Defaults[.shortcutsControllerSettings].count) {
            return shortcutsControllers[index]
        }
        
        // -1, -2, ...
        else if (index < 0 && abs(index) <= defaultControllers.count) {
            return defaultControllers[abs(index) - 1]
        }
        
        return nil
    }
    
    static func insert(at index: Int) {
        shortcutsControllers.insert(contentsOf: [ShortcutsController(settings: ShortcutsController.Settings())], at: index)
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
    
    static func toggle(_ activated: Bool, index: Int) {
        if (activated) {
            Defaults[.activatedControllerIndexes].append(index)
        } else {
            if let i = Defaults[.activatedControllerIndexes].firstIndex(of: index) {
                Defaults[.activatedControllerIndexes].remove(at: i)
            }
        }
    }
    
    static func reorder(fetchAt: Int, insertAt: Int) {
        guard
            fetchAt != insertAt
                && fetchAt >= 0 && insertAt >= 0
                && fetchAt < Defaults[.activatedControllerIndexes].count && insertAt <= Defaults[.activatedControllerIndexes].count
        else { return }
        
        let instance = Defaults[.activatedControllerIndexes].remove(at: fetchAt)
        Defaults[.activatedControllerIndexes].insert(instance, at: insertAt)
    }
    
}
