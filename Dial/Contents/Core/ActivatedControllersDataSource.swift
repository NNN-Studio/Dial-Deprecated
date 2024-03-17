//
//  ActivatedControllersDataSource.swift
//  Dial
//
//  Created by KrLite on 2024/3/17.
//

import Foundation
import AppKit
import Defaults

class ActivatedControllersDataSource: NSTableViewDiffableDataSource<String, ControllerID> {
    
    func tableView(
        _ tableView: NSTableView, pasteboardWriterForRow row: Int
    ) -> (any NSPasteboardWriting)? {
        print(1)
        let item = NSPasteboardItem()
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(Defaults[.activatedControllerIDs][row]) else { return nil }
        
        item.setData(data, forType: ControllerID.pasteboardType)
        return item
    }
    
    func tableView(
        _ tableView: NSTableView, draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint, operation: NSDragOperation
    ) {
        print(2)
    }
    
    func tableView(
        _ tableView: NSTableView, validateDrop info: NSDraggingInfo,
        proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation
    ) -> NSDragOperation {
        if dropOperation == .above {
            if info.draggingSourceOperationMask.contains(.move) {
                return .move
            }
            
            if info.draggingSourceOperationMask.contains(.copy) {
                return .copy
            }
        }
        return []
    }
    
    func tableView(
        _ tableView: NSTableView, acceptDrop info: NSDraggingInfo, 
        row: Int, dropOperation: NSTableView.DropOperation
    ) -> Bool {
        true
    }
    
}
