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

class ModifiersMenuItems {
    
    let delegate: DialModifiersMenuDelegate
    
    let actionTarget: ModifiersOptionItem.ActionTarget
    
    private var titleCache = ""
    
    init(
        delegate: DialModifiersMenuDelegate,
        actionTarget: ModifiersOptionItem.ActionTarget
    ) {
        self.delegate = delegate
        self.actionTarget = actionTarget
        self.modifierOptions = [
            .init(title: titleCache),
            ModifiersOptionItem("􀆔", option: .command, actionTarget: actionTarget),
            ModifiersOptionItem("􀆕", option: .option, actionTarget: actionTarget),
            ModifiersOptionItem("􀆍", option: .control, actionTarget: actionTarget),
            ModifiersOptionItem("􀆝", option: .shift, actionTarget: actionTarget)
        ]
    }
    
    private func initialize() {
        for option in modifierOptions.filter({ $0 is ModifiersOptionItem }) {
            option.target = delegate
            option.action = #selector(delegate.setModifiers(_:))
        }
        if let value = Controllers.selectedSettings?.shortcuts.getModifiersFor(actionTarget) {
            updateModifierOptions(value)
        }
    }
    
    var modifierOptions: [NSMenuItem] = []
    
}

extension ModifiersMenuItems {
    
    func updateModifierOptions(_ value: NSEvent.ModifierFlags) {
        for option in modifierOptions.compactMap({ $0 as? ModifiersOptionItem }) {
            option.flag = value.contains(option.option)
        }
        
        let string = modifierOptions
            .filter { $0.flag }
            .map { $0.title }
            .joined()
        
        modifierOptions[0].title = string
        titleCache = string
    }
    
}
