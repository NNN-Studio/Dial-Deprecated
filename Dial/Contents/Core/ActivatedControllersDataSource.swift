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
    
    public static let section = "ActivatedControllersSection"
    
    func onDataSourceSnapshot(
        snapshotOperation: (inout NSDiffableDataSourceSnapshot<String, ControllerID>) -> Void,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = snapshot()
        snapshotOperation(&snapshot)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    @objc func tableView(
        _ tableView: NSTableView,
        writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard
    ) -> Bool {
        true
    }
    
    @objc func tableView(
        _ tableView: NSTableView, pasteboardWriterForRow row: Int
    ) -> (any NSPasteboardWriting)? {
        let pboard = NSPasteboardItem()
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(Defaults[.activatedControllerIDs][row]) else { return nil }
        
        pboard.setData(data, forType: ControllerID.pasteboardType)
        return pboard
    }
    
    
    
    @objc func tableView(
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
    
    @objc func tableView(
        _ tableView: NSTableView, acceptDrop info: NSDraggingInfo,
        row targetIndex: Int, dropOperation: NSTableView.DropOperation
    ) -> Bool {
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }
        
        let decoder = JSONDecoder()
        guard
            let data = items[0].data(forType: ControllerID.pasteboardType),
            let source = try? decoder.decode(ControllerID.self, from: data)
        else { return false }
        
        guard
            let sourceIndex = row(forItemIdentifier: source),
            let target = itemIdentifier(forRow: targetIndex),
            source != target
        else {
            // Didn't move
            return false
        }
        
        var snapshot = self.snapshot()
        snapshot.moveItem(source, beforeItem: target) // Moves
        Defaults[.activatedControllerIDs] = snapshot.itemIdentifiers // Update and save
        apply(snapshot, animatingDifferences: false)
        
        return true
    }
    
}
