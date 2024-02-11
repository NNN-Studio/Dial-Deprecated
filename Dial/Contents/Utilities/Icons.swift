//
//  Icons.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import AppKit
import SFSafeSymbols

struct Icon: Codable {
    
    static let suffix = ".circle.fill"
    
    var symbol: SFSymbol
    
    init?(_ symbol: SFSymbol) {
        guard Icons.availableSymbols.contains(symbol) else { return nil }
        
        self.symbol = symbol
    }
    
    var outline: NSImage {
        NSImage(systemSymbol: symbol)
    }
    
    var filled: NSImage {
        NSImage(systemSymbol: symbol.withSuffix(Icon.suffix)!)
    }
    
}

struct Icons {
    
    static let fallbackIcon = Icon(.questionmark)!
    
    static var availableSymbols: [SFSymbol] {
        SFSymbol.allSymbols
            .filter { $0.hasSuffix(Icon.suffix) && $0.withoutSuffix(Icon.suffix) != nil }
            .map { $0.withoutSuffix(Icon.suffix)! }
    }
    
}

extension SFSymbol {
    
    func hasSuffix(_ suffix: String) -> Bool {
        rawValue.hasSuffix(suffix)
    }
    
    func withSuffix(_ suffix: String) -> SFSymbol? {
        let name = rawValue + "." + suffix.replacing(/^\./, with: "")
        return SFSymbol.allSymbols.filter { $0.rawValue == name }.first
    }
    
    func withoutSuffix(_ suffix: String) -> SFSymbol? {
        guard hasSuffix(suffix) else { return nil }
        
        let name = rawValue.replacing("." + suffix.replacing(/^\./, with: ""), with: "")
        return SFSymbol.allSymbols.filter { $0.rawValue == name }.first
    }
    
}

extension SFSymbol: Codable {
    
    // Make it codable
    
}
