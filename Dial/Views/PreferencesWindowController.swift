//
//  PreferencesWindowController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController {
    
    static let shared: PreferencesWindowController = {
        return NSStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateController(withIdentifier: "Main") as! PreferencesWindowController
    }()

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.contentView = NSHostingView(rootView: PreferencesView())
    }

}
