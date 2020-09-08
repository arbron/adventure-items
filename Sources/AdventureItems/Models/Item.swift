//
//  Item.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation

struct Item: Codable, Hashable {
    var name: String
    var rarity: Rarity
    var consumable: Bool
    var count: Int?

    enum Rarity: String, Codable {
        case common, uncommon, rare, veryRare, legendary

        var name: String {
            switch self {
            case .veryRare: return "very rare"
            default: return rawValue
            }
        }
    }
}
