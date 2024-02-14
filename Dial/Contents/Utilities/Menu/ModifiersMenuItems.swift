//
//  ModifiersMenuItems.swift
//  Dial
//
//  Created by KrLite on 2024/2/14.
//

import Foundation
import AppKit
import SFSafeSymbols
import Defaults

@objc protocol DialModifiersMenuDelegate {
    
    @objc func setModifiers(_ sender: Any?)
    
}

struct ModifiersMenuItems {
    
    let delegate: DialModifiersMenuDelegate
    
    let actionTarget: ModifiersOptionItem.ActionTarget
    
    var modifiersOptions: [NSMenuItem] {
        let options: [ModifiersOptionItem] = [
            .init("􀆔", option: .command, actionTarget: actionTarget),
            .init("􀆕", option: .option, actionTarget: actionTarget),
            .init("􀆍", option: .control, actionTarget: actionTarget),
            .init("􀆝", option: .shift, actionTarget: actionTarget)
        ]
        
        let title = NSMenuItem(title: "")
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setModifiers(_:))
            
            Task { @MainActor in
                for await _ in Defaults.updates(.shortcutsControllerSettings) {
                    for controller in Controllers.shortcutsControllers {
                        if controller.id == Controllers.selectedController.id {
                            option.flag = controller.settings.shortcuts.getModifiersOf(actionTarget).contains(option.option)
                        }
                    }
                    
                    title.title = options
                        .filter { $0.flag }
                        .map { $0.title }
                        .joined()
                }
            }
        }
        
        var items: [NSMenuItem] = []
        
        items.append(title)
        items.append(contentsOf: options)
        
        return items
    }
    
}
