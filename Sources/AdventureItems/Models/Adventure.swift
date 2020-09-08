//
//  Adventure.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation

struct Adventure: Codable, Hashable {
    var code: String
    var name: String
    var description: String

    var released: Date?

    var source: Source { Source(code) }

    var items: [Item]
    var spellbooks: [Spellbook]
    var storyAwards: [StoryAward]
    

    private static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        return formatter
    }
    enum Source {
        case season(Int)
        case hardcover
        case conventionCreatedContent(String)

        init(_ code: String) {
            if let remainder = code.removePrefix("CCC-") {
                guard let dashIdx = remainder.firstIndex(of: "-") else { fatalError("Invalid CCC code: \(code)") }
                self = .conventionCreatedContent("\(remainder.prefix(upTo: dashIdx))")
            } else if let remainder = code.removePrefix("DDAL") ?? code.removePrefix("DDEX") ?? code.removePrefix("DDEP") {
                guard let seasonNum = Adventure.formatter.number(from: "\(remainder.prefix(2))") else { fatalError("Invalid Season code: \(code)") }
                self = .season(seasonNum.intValue)
            } else if let _ = code.removePrefix("DDHC-") {
                self = .hardcover
            } else {
                fatalError("Invalid adventure code: \(code)")
            }
        }
    }
}
