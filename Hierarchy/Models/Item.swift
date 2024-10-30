//
//  ItemModel.swift
//  Hierarchy
//
//  Created by macbook on 19.10.2024.
//
import Foundation

struct Item: Identifiable, Decodable, Hashable {
    let id: UUID = UUID()
    var data: [String: String]
    var children: ChildData

    enum CodingKeys: String, CodingKey {
        case data
        case children
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([String: String].self, forKey: .data)

        if let childrenDict = try? container.decode([String: ItemChildren].self, forKey: .children) {
            self.children = .dictionary(childrenDict)
        } else {
            self.children = .empty
        }
    }
}

