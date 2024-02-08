//
//  MenuManager.swift
//  Dial
//
//  Created by KrLite on 2023/10/29.
//

import Foundation
import AppKit

extension NSMenuItem {
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    var flag: Bool {
        get {
            state == .on
        }
        
        set(flag) {
            state = flag ? .on : .off
        }
    }
    
}


class MenuOptionItem<Type>: NSMenuItem {
    
    init(_ title: String, option: Type) {
        super.init(title: title, action: nil, keyEquivalent: "")
        self.representedObject = option
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var option : Type {
        self.representedObject as! Type
    }
    
}

class ControllerOptionItem: MenuOptionItem<DefaultDialMode> {
    
    let controller: Controller
    
    init(_ title: String, mode: DefaultDialMode, controller: Controller) {
        self.controller = controller
        super.init(title, option: mode)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class StateOptionItem: MenuOptionItem<NSControl.StateValue> {
    
    init(_ title: String) {
        super.init(title, option: .mixed)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct MenuManager {
    
    typealias MenuItemGroup = (title: (content: String?, badge: String?), options: [NSMenuItem])
    
    let menu = NSMenu()
    
    let items: [MenuItemGroup]
    
    init(delegate: NSMenuDelegate? = nil, _ items: () -> [MenuItemGroup]) {
        self.items = items()
        menu.autoenablesItems = false
        menu.delegate = delegate
        
        for (index, (title, group)) in self.items.enumerated() {
            // Add separator
            
            if index > 0 {
                menu.addItem(NSMenuItem.separator())
            }
            
            // Add title
            
            if let titleContent = title.content {
                let titleItem = NSMenuItem(title: titleContent)
                titleItem.isEnabled = false
                
                if #available(macOS 14.0, *) {
                    if let titleBadge = title.badge {
                        titleItem.badge = NSMenuItemBadge(string: titleBadge)
                    }
                }
                
                menu.addItem(titleItem)
            }
            
            group.forEach(menu.addItem(_:))
        }
    }
    
    static func groupItems(
        title: String? = nil,
        badge: String? = nil,
        _ items: [NSMenuItem]
    ) -> MenuItemGroup {
        ((title, badge), items)
    }
    
    static func groupItems(
        title: String? = nil,
        badge: String? = nil,
        _ items: NSMenuItem...
    ) -> MenuItemGroup {
        groupItems(title: title, badge: badge, items)
    }
    
}
