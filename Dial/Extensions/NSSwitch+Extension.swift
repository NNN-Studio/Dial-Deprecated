//
//  NSSwitch+Extension.swift
//  Dial
//
//  Created by KrLite on 2024/2/12.
//

import AppKit

extension NSSwitch {
    
    var flag: Bool {
        get {
            self.state == .on
        }
        
        set(flag) {
            self.state = flag ? .on : .off
        }
    }
    
}
