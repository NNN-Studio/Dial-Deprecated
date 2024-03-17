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
    
    @IBOutlet weak var buttonRemove: NSButton!
    
    func set(_ controller: Controller) {
        print(controller.name)
        labelName.stringValue = controller.name
        
        if controller.isDefaultController {
            labelSubtitle.isHidden = false
            labelSubtitle.stringValue = ""
            labelSubtitle.placeholderString = NSLocalizedString("Table/Subtitle/Default", value: "Default", comment: "default controller subtitle")
        } else {
            labelSubtitle.isHidden = true
        }
        
        if Controllers.activatedControllers.count > 1 {
            buttonRemove.isHidden = false
            buttonRemove.showsBorderOnlyWhileMouseInside = true
        } else {
            buttonRemove.isHidden = true
        }
        
        imageIcon.image = controller.representingSymbol.image
    }
    
}
