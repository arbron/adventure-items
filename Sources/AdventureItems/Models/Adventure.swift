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
    var description: String

    var released: Date?

//    var source: Source {
//        .season(1)
//    }

    var items: [Item]
    var spellbooks: [Spellbook]
    var storyAwards: [StoryAward]

//    enum Source {
//        case season(Int)
//        case conventionCreatedContent
//
//        init(_ code: String) {
//            if code.hasPrefix("CCC") {
//                self = .conventionCreatedContent
//            } else {
//                let season = code[4...6]
//            }
//        }
//    }
}
