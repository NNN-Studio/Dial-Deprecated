//
//  PreferencesViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa
import SwiftUI

class PreferencesViewController: NSTabViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

class PreferencesControllersViewController: NSViewController {
    
    override func viewDidLoad() {
        view = NSHostingView(rootView: ControllersView())
    }
    
}

class PreferencesDialViewController: NSViewController {
    
    override func viewDidLoad() {
        view = NSHostingView(rootView: DialView())
    }
    
}
