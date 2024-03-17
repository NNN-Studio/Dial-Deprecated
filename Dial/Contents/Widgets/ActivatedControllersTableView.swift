//
//  ActivatedControllersTableView.swift
//  Dial
//
//  Created by KrLite on 2024/3/17.
//

import Foundation
import AppKit

class ActivatedControllersTableView: NSTableView {
    
    override func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        switch context {
        case .outsideApplication:
            [.delete]
        case .withinApplication:
            [.move]
        @unknown default:
            [.generic]
        }
    }
    
}
