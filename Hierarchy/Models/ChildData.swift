//
//  ChildData.swift
//  Hierarchy
//
//  Created by macbook on 25.10.2024.
//
import Foundation

enum ChildData: Hashable, Equatable {
    case dictionary([String: ItemChildren])
    case empty

    static func == (lhs: ChildData, rhs: ChildData) -> Bool {
        switch (lhs, rhs) {
        case (.dictionary(let lhsDict), .dictionary(let rhsDict)):
            return lhsDict == rhsDict
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
