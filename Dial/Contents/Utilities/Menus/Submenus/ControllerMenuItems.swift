//
//  ControllerMenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/13.
//

import Foundation
import Defaults
import AppKit

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
        
        var modifiers: NSEvent.ModifierFlags {
            switch self {
            case .default:
                    .command
            case .shortcuts:
                    .option
            case .activated:
                []
            }
        }
        
    }
    
    let delegate: DialControllerMenuDelegate
    
    let source: ControllersSource
    
    init(
        delegate: DialControllerMenuDelegate,
        source: ControllersSource
    ) {
        self.delegate = delegate
        self.source = source
        
        self.controllers = source.fetch.enumerated().map {
            let controller = $0.element
            let index = $0.offset
            let item = ControllerOptionItem(controller.name, option: controller)
            
            item.target = delegate
            item.action = #selector(delegate.setController(_:))
            item.image = controller.representingSymbol.image
            
            if index <= 9 {
                item.keyEquivalent = String(index)
                item.keyEquivalentModifierMask = source.modifiers
            }
            
            if let shortcutsController = item.option as? ShortcutsController {
                for controller in Controllers.shortcutsControllers {
                    if controller.id == shortcutsController.id {
                        item.image = controller.representingSymbol.image
                        item.title = controller.name
                    }
                }
            }
            
            if (source == .activated) {
                item.flag = item.option.id == Controllers.currentController.id
            } else {
                let activated = Controllers.activatedControllers.contains(where: { $0.id == item.option.id })
                
                item.mixedStateImage =
                item.option.id == Controllers.currentController.id
                ? NSImage(named: NSImage.menuMixedStateTemplateName)
                : NSImage(systemSymbol: .ellipsis)
                
                if item.option.id == Controllers.selectedController.id {
                    item.state = .on
                } else {
                    item.state = activated ? .mixed : .off
                }
            }
            
            return item
        }
    }
    
    var controllers: [ControllerOptionItem]
    
}
