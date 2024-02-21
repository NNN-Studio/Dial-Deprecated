//
//  SettingsTabViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/21.
//

import Foundation
import AppKit

class SettingsTabViewController: NSTabViewController {
    
    @IBOutlet weak var tabViewItemGeneral: NSTabViewItem!
    
    @IBOutlet weak var tabViewItemControllers: NSTabViewItem!
    
}

extension SettingsTabViewController {
    
    override func viewDidLoad() {
        tabViewItemGeneral.viewController = AppDelegate.shared?.generalViewController
        tabViewItemControllers.viewController = AppDelegate.shared?.controllersViewController
    }
    
}
