//
//  ImportedItem.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

import AdventureUtils


struct ImportedItem: Codable, Hashable {
    var name: String
    var formattedName: String?

    @DecodableDefault.EmptyList var subtypes: [Subtype]

    struct Subtype: Codable, Hashable {
        var name: String
        var rarity: Item.Rarity
    }

    @DecodableDefault.True var consumable: Bool
    @DecodableDefault.False var illegal: Bool
}
