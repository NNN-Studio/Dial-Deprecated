//
//  ActivatedControllersDataSource.swift
//  Dial
//
//  Created by KrLite on 2024/3/17.
//

import Foundation
import AppKit
import Defaults

// A related bug: https://forums.developer.apple.com/forums/thread/709343
class ActivatedControllersDataSource: NSTableViewDiffableDataSource<String, ControllerID> {
    
    @objc func tableView(
        _ tableView: NSTableView,
        writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard
    ) -> Bool {
        print(0)
        return true
    }
    
    @objc func tableView(
        _ tableView: NSTableView, pasteboardWriterForRow row: Int
    ) -> (any NSPasteboardWriting)? {
        print(1)
        let item = NSPasteboardItem()
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(Defaults[.activatedControllerIDs][row]) else { return nil }
        
        item.setData(data, forType: ControllerID.pasteboardType)
        return item
    }
    
    @objc func tableView(
        _ tableView: NSTableView, draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint, operation: NSDragOperation
    ) {
        print(2)
    }
    
    @objc func tableView(
        _ tableView: NSTableView, validateDrop info: NSDraggingInfo,
        proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation
    ) -> NSDragOperation {
        print(3)
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
    
    @objc func tableView(
        _ tableView: NSTableView, acceptDrop info: NSDraggingInfo,
        row: Int, dropOperation: NSTableView.DropOperation
    ) -> Bool {
        print(4)
        return true
    }
    
}
