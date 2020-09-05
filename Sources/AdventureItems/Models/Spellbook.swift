//
//  Spellbook.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation

struct Spellbook: Codable {
    var name: String
    var spells: [Spell]
}

struct Spell: Codable {
    var name: String
}
