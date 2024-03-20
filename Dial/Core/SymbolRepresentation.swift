//
//  SymbolRepresentation.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import SFSafeSymbols
import AppKit

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
