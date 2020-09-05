//
//  Adventure.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation

struct Adventure: Codable {
    var code: String
    var name: String

    var items: [Item]
    var spellbooks: [Spellbook]
    var storyAwards: [StoryAward]
}
