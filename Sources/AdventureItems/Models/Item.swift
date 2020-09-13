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
    @DecodableDefault.EmptyList var properties: [String]
    @DecodableDefault.False var illegal: Bool
    @DecodableDefault.False var consumable: Bool
    var count: Int?

    enum Rarity: String, Codable {
        case common, uncommon, rare, veryRare, legendary, unique

        var name: String {
            switch self {
            case .veryRare: return "Very Rare"
            default: return rawValue.uppercaseFirst()
            }
        }
    }
}
