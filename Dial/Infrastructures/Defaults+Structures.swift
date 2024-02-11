//
//  Defaults+Structures.swift
//  Dial
//
//  Created by KrLite on 2024/2/9.
//

import Foundation
import Defaults

/// Decides how much steps per circle the dial is divided into.
enum Sensitivity: CGFloat, CaseIterable, Defaults.Serializable {
    
    case low = 5
    
    case medium = 7
    
    case natural = 10
    
    case high = 30
    
    case extreme = 45
    
    /// Decides how much steps per circle the dial is divided into in continuous rotation.
    var continuous: CGFloat {
        switch self {
        case .low:
            60
        case .medium:
            90
        case .natural:
            120
        case .high:
            240
        case .extreme:
            360
        }
    }
    
    var gap: (stepping: CGFloat, continuous: CGFloat) {
        (stepping: 360 / rawValue, continuous: 360 / self.continuous)
    }
    
}

enum Direction: Int, CaseIterable, Codable, Defaults.Serializable {
    
    case clockwise = 1
    
    /// Basically, the rotation of dial is inverted.
    case counterclockwise = -1
    
    var negate: Direction {
        switch self {
        case .clockwise:
                .counterclockwise
        case .counterclockwise:
                .clockwise
        }
    }
    
    var physical: Direction {
        self.multiply(Defaults[.direction])
    }
    
    func negateIf(_ flag: Bool) -> Direction {
        flag ? negate : self
    }
    
    func multiply(_ another: Direction) -> Direction {
        switch another {
        case .clockwise:
            self
        case .counterclockwise:
            self.negate
        }
    }
    
}

struct Bag<Element: Defaults.Serializable>: Collection {
    
    var items: [Element]
    
    var startIndex: Int { items.startIndex }
    
    var endIndex: Int { items.endIndex }
    
    mutating func insert(element: Element, at: Int) {
        items.insert(element, at: at)
    }
    
    func index(after index: Int) -> Int {
        items.index(after: index)
    }
    
    subscript(position: Int) -> Element {
        items[position]
    }
    
}

extension Bag: Defaults.CollectionSerializable {
    
    init(_ elements: [Element]) {
        self.items = elements
    }
    
}

enum Wrapper {
    
    
    
}
