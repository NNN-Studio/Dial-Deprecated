//
//  Icons.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import AppKit

struct Icon: Codable {
    
    static let suffix = ".circle.fill"
    
    var path: String
    
    init?(_ path: String) {
        print(Icons.allPaths.count)
        guard Icons.availablePaths.contains(path) else { return nil }
        
        self.path = path
    }
    
    var outline: NSImage {
        NSImage(systemSymbolName: path, accessibilityDescription: nil)!
    }
    
    var filled: NSImage {
        NSImage(systemSymbolName: path + Icon.suffix, accessibilityDescription: nil)!
    }
    
}

struct Icons {
    
    static let fallbackIcon = Icon("questionmark")!
    
    static var allPaths: [String] {
        if
            let sfSymbolsBundle = Bundle(identifier: "com.apple.SFSymbolsFramework"),
            let bundlePath = sfSymbolsBundle.path(forResource: "CoreGlyphs", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let resourcePath = bundle.path(forResource: "symbol_search", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath)
        {
            return plist.allKeys.map { $0 as! String }
        }
        
        return []
    }
    
    static var availablePaths: [String] {
        allPaths.filter { $0.hasSuffix(Icon.suffix) }.map { $0.replacing(Icon.suffix, with: "") }
    }
    
}
