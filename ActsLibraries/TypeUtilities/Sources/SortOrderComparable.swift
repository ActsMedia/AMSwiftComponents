//
//  SortOrderComparable.swift
//  
//
//  Created by Paul Fechner on 1/2/20.
//

import Foundation

public protocol SortOrderComparable: Comparable {
    var sortOrder: Int { get }
}

public protocol SortOrderOptionalComparable: Comparable {
    var sortOrder: Int? { get }
}

extension SortOrderOptionalComparable {
    public static func <(_ left: Self, _ right: Self) -> Bool {
        (left.sortOrder ?? 0) < (right.sortOrder ?? 0)
    }
}

extension SortOrderComparable {
    public static func <(_ left: Self, _ right: Self) -> Bool {
        left.sortOrder < right.sortOrder
    }
}
