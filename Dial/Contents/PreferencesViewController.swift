//
//  PreferencesViewController.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet var viewMain: NSView!
    
    @IBOutlet weak var tabViewMain: NSTabView!
    
    @IBOutlet weak var tabViewItemControllers: NSTabViewItem!
    
    @IBOutlet weak var tabViewitemDial: NSTabViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension PreferencesViewController {
    
    @IBAction func select(
        _ sender: Any?
    ) {
        
    }
    
}
