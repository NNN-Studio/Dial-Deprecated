//
//  ControllerMenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/13.
//

import Foundation
import Defaults

@objc protocol DialControllerMenuDelegate: AnyObject {
    
    @objc func setController(_ sender: Any?)
    
}

struct ControllerMenuItems {
    
    enum ControllersSource {
        
        case `default`
        
        case shortcuts
        
        case activated
        
        var fetch: [Controller] {
            switch self {
            case .`default`:
                Controllers.defaultControllers
            case .shortcuts:
                Controllers.shortcutsControllers
            case .activated:
                Controllers.activatedControllers
            }
        }
        
    }
    
    let delegate: DialControllerMenuDelegate
    
    let source: ControllersSource
    
    var controllers: [ControllerOptionItem] {
        source.fetch.map { controller in
            let item = ControllerOptionItem(controller.name, controller: controller)
            
            item.target = delegate
            item.action = #selector(delegate.setController(_:))
            item.image = controller.representingSymbol.raw
            
            Task { @MainActor in
                for await _ in Defaults.updates(.shortcutsControllerSettings) {
                    if let shortcutsController = item.option as? ShortcutsController {
                        for controller in Controllers.shortcutsControllers {
                            if controller.id == shortcutsController.id {
                                item.image = controller.representingSymbol.raw
                                item.title = controller.name
                            }
                        }
                    }
                }
            }
            
            if (source == .activated) {
                Task { @MainActor in
                    for await value in Defaults.updates(.currentControllerID) {
                        item.flag = item.option.id == value
                    }
                }
            } else {
                Task { @MainActor in
                    for await _ in Defaults.updates([
                        .selectedControllerID,
                        .activatedControllerIDs
                    ]) {let activated = Controllers.activatedControllers.contains(where: { $0.id == item.option.id })
                        
                        if item.option.id == Controllers.selectedController.id {
                            item.state = .on
                        } else {
                            item.state = activated ? .mixed : .off
                        }
                    }
                }
            }
            
            return item
        }
    }
    
}
