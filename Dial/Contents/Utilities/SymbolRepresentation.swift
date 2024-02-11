//
//  SymbolRepresentation.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import SFSafeSymbols
import AppKit

extension SFSymbol {
    
    static let circleFillSuffix = ".circle.fill"
    
    static let fallback: SFSymbol = .questionmark
    
    static var circleFillableSymbols: [SFSymbol] {
        SFSymbol.allSymbols
            .filter { $0.hasSuffix(SFSymbol.circleFillSuffix) && $0.withoutSuffix(SFSymbol.circleFillSuffix) != nil }
            .map { $0.withoutSuffix(SFSymbol.circleFillSuffix)! }
    }
    
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

extension SFSymbol {
    
    var isCircleFillable: Bool {
        SFSymbol.circleFillableSymbols.contains(self)
    }
    
    var raw: NSImage {
        NSImage(systemSymbol: self)
    }
    
    var circleFilled: NSImage {
        NSImage(systemSymbol: self.withSuffix(SFSymbol.circleFillSuffix) ?? .fallback)
    }
    
}

extension SFSymbol: Codable {
    
    // Make it codable
    
}

protocol SymbolRepresentable {
    
    var representingSymbol: SFSymbol { get }
    
}

enum SymbolRepresentation: Codable {
    
    case dial
    
}

extension SymbolRepresentation: SymbolRepresentable {
    
    var representingSymbol: SFSymbol {
        switch self {
        case .dial:
            .hockeyPuckFill
        }
    }
    
}
