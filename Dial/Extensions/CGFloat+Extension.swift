//
//  CGFloat+Extension.swift
//  Dial
//
//  Created by KrLite on 2024/2/18.
//

import Foundation

extension CGFloat {
    
    func squareRootWithSign() -> CGFloat {
        let sqrt = abs(self).squareRoot()
        return switch sign {
        case .plus:
            sqrt
        case .minus:
            -sqrt
        }
    }
    
}
