//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Publish

extension Tag {
    var tagClass: String? {
        if self.string.hasPrefix("spell: ") {
            return "spell"
        } else if self.string.hasPrefix("rarity: ") {
            return "rarity"
        } else {
            return nil
        }
    }
}
