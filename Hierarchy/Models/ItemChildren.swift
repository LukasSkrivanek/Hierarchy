//
//  ItemChildren.swift
//  Hierarchy
//
//  Created by macbook on 25.10.2024.
//
import Foundation

struct ItemChildren: Identifiable, Decodable, Hashable {
    let id: String
    var records: [Item]

    enum CodingKeys: String, CodingKey {
        case records
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.records = try container.decode([Item].self, forKey: .records)
    }
}
