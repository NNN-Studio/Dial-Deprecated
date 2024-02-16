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

class ModifiersMenuItems { // It needs to be self mutable
    
    let delegate: DialModifiersMenuDelegate
    
    let actionTarget: ModifiersOptionItem.ActionTarget
    
    private var titleCache = ""
    
    init(
        delegate: DialModifiersMenuDelegate,
        actionTarget: ModifiersOptionItem.ActionTarget
    ) {
        self.delegate = delegate
        self.actionTarget = actionTarget
    }
    
    var modifiersOptions: [NSMenuItem] {
        let options: [ModifiersOptionItem] = [
            .init("􀆔", option: .command, actionTarget: actionTarget),
            .init("􀆕", option: .option, actionTarget: actionTarget),
            .init("􀆍", option: .control, actionTarget: actionTarget),
            .init("􀆝", option: .shift, actionTarget: actionTarget)
        ]
        
        let title = NSMenuItem(title: titleCache)
        
        for option in options {
            option.target = delegate
            option.action = #selector(delegate.setModifiers(_:))
            
            Task { @MainActor in
                for await value in Defaults.updates(.shortcutsControllerSettings) {
                    for settings in value {
                        if let selectedSettings = Controllers.selectedSettings, settings.id == selectedSettings.id {
                            let flag = settings.shortcuts.getModifiersOf(actionTarget).contains(option.option)
                            option.flag = flag
                        }
                    }
                }
            }
        }
        
        Task { @MainActor in
            for await _ in Defaults.updates(.shortcutsControllerSettings) {
                let string = options
                    .filter { $0.flag }
                    .map { $0.title }
                    .joined()
                
                title.title = string
                titleCache = string
            }
        }
        
        var items: [NSMenuItem] = []
        
        items.append(title)
        items.append(contentsOf: options)
        
        return items
    }
    
}
