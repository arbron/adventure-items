//
//  Spellbook.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation
import AdventureUtils

struct Spellbook: Codable, Hashable {
    var name: String
    @DecodableDefault.EmptyString var flavor: String
    var spells: [Spell]
    @DecodableDefault.EmptyString var note: String
}

struct Spell: Codable, Hashable {
    var name: String
    var level: Int
}
