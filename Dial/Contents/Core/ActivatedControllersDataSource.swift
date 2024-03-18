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
    
    public static let section = "ActivatedControllersSection"
    
    override init(
        tableView: NSTableView,
        cellProvider: @escaping CellProvider
    ) {
        super.init(tableView: tableView, cellProvider: cellProvider)
        
        var snapshot = NSDiffableDataSourceSnapshot<String, ControllerID>()
        snapshot.appendSections([ActivatedControllersDataSource.section])
        snapshot.appendItems(Defaults[.activatedControllerIDs], toSection: ActivatedControllersDataSource.section)
        apply(snapshot, animatingDifferences: false)
    }
    
    func onDataSourceSnapshot(
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil,
        snapshotOperation: (inout NSDiffableDataSourceSnapshot<String, ControllerID>) -> Void
    ) {
        var snapshot = snapshot()
        snapshotOperation(&snapshot)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    @objc func tableView(
        _ tableView: NSTableView,
        writeRowsWith rowIndexes: IndexSet, 
        to pboard: NSPasteboard
    ) -> Bool {
        true
    }
    
    @objc func tableView(
        _ tableView: NSTableView, 
        pasteboardWriterForRow row: Int
    ) -> (any NSPasteboardWriting)? {
        let pboard = NSPasteboardItem()
        
        guard let data = try? JSONEncoder().encode(Defaults[.activatedControllerIDs][row]) else { return nil }
        
        pboard.setData(data, forType: ControllerID.pasteboardType)
        return pboard
    }
    
    
    
    @objc func tableView(
        _ tableView: NSTableView, 
        validateDrop info: NSDraggingInfo,
        proposedRow row: Int, 
        proposedDropOperation dropOperation: NSTableView.DropOperation
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
        _ tableView: NSTableView, 
        acceptDrop info: NSDraggingInfo,
        row targetIndex: Int, 
        dropOperation: NSTableView.DropOperation
    ) -> Bool {
        guard let items = info.draggingPasteboard.pasteboardItems else { return false }
        
        guard
            let data = items[0].data(forType: ControllerID.pasteboardType),
            let source = try? JSONDecoder().decode(ControllerID.self, from: data)
        else { return false }
        
        guard
            let target = itemIdentifier(forRow: targetIndex),
            source != target
        else {
            // Didn't move
            return false
        }
        
        onDataSourceSnapshot(animatingDifferences: false) { snapshot in
            snapshot.moveItem(source, beforeItem: target) // Moves
            Defaults[.activatedControllerIDs] = snapshot.itemIdentifiers // Update and save
        }
        
        return true
    }
    
    // This is a toxic behaviour. See https://forums.developer.apple.com/forums/thread/709343
    @objc func tableView(
        _ tableView: NSTableView,
        draggingSession session: NSDraggingSession,
        endedAtPoint screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        self.tableView(tableView, draggingSession: session, endedAt: screenPoint, operation: operation)
    }
    
    @objc func tableView(
        _ tableView: NSTableView,
        draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        if operation == .delete {
            guard Defaults[.activatedControllerIDs].count > 1 else { return }
            
            guard
                let items = session.draggingPasteboard.pasteboardItems,
                let data = items[0].data(forType: ControllerID.pasteboardType),
                let controllerId = try? JSONDecoder().decode(ControllerID.self, from: data),
                let row = row(forItemIdentifier: controllerId)
            else { return }
            
            guard let controller = Controllers.fetch(controllerId) else { return }
            
            //Controllers.toggle(false, controller: controller)
            tableView.removeRows(at: .init(integer: row))
        }
    }
    
}
