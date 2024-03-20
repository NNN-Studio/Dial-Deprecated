//
//  ActivatedControllerCell.swift
//  Dial
//
//  Created by KrLite on 2024/3/17.
//

import Foundation
import AppKit

class ActivatedControllerCell: NSTableCellView {
    
    @IBOutlet weak var labelName: NSTextField!
    
    @IBOutlet weak var labelSubtitle: NSTextField!
    
    @IBOutlet weak var imageIcon: NSImageView!
    
    @IBOutlet weak var buttonBecomeCurrent: NSButton!
    
    private var controller: Controller?
    
    func set(_ controller: Controller) {
        self.controller = controller
        
        labelName.stringValue = controller.name
        
        if controller.isDefaultController {
            labelSubtitle.isHidden = false
            labelSubtitle.stringValue = ""
            labelSubtitle.placeholderString = NSLocalizedString("Table/Subtitle/Default", value: "Default", comment: "default controller subtitle")
        } else {
            labelSubtitle.isHidden = true
        }
        
        if controller.id == Controllers.currentController.id {
            buttonBecomeCurrent.isEnabled = false
            
            buttonBecomeCurrent.animator().image = NSImage(systemSymbol: .checkmark)
        } else {
            buttonBecomeCurrent.isEnabled = true
            
            buttonBecomeCurrent.animator().image = NSImage(systemSymbol: .starFill)
        }
        
        buttonBecomeCurrent.showsBorderOnlyWhileMouseInside = true
        imageIcon.image = controller.representingSymbol.image
    }
    
    @IBAction func becomeCurrent(_ sender: NSButton) {
        guard let controller else { return }
        Controllers.currentController = controller
    }
    
}
