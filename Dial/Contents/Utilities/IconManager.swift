//
//  IconManager.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation

struct IconManager {
    
    static let suffix = ".circle.fill"
    
    static var allIcons: [String] {
        if
            let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
            let resourcePath = bundle.path(forResource: "symbol_search", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath)
        {
            return plist.allKeys.map { $0 as! String }
        }
        
        return []
    }
    
    static var availableIcons: [String] {
        allIcons.filter { $0.hasSuffix(suffix) }.map { $0.replacing(suffix, with: "") }
    }
    
}
