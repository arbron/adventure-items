//
//  Item.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation
import AdventureUtils

struct Item: Codable, Hashable {
    var name: String
    var rarity: Rarity
    @DecodableDefault.EmptyList var properties: [String]
    @DecodableDefault.False var consumable: Bool
    var count: Int?

    @DecodableDefault.EmptyString var flavor: String

    @DecodableDefault.False var illegal: Bool
    @DecodableDefault.False var storyItem: Bool
    var guidance: String?

    enum Rarity: String, Codable {
        case common, uncommon, rare, veryRare, legendary, unique

        var name: String {
            return "rarity.\(rawValue)".localized()
        }
    }
}
