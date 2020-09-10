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

    @DecodableDefault.False var incomplete: Bool

    var released: Date?

    @DecodableDefault.EmptyList var items: [Item]
    @DecodableDefault.EmptyList var spellbooks: [Spellbook]
    @DecodableDefault.EmptyList var storyAwards: [StoryAward]

    var source: Source { Source(code) }
    var isEpic: Bool { code.hasPrefix("DDEP") || code.hasPrefix("DDAL-EBEP") }
}

extension Adventure {
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
        case dreamsOfRedWizards
        case oracleOfWar

        init(_ code: String) {
            if let remainder = code.removePrefix("CCC-") {
                guard let dashIdx = remainder.firstIndex(of: "-") else { fatalError("Invalid CCC code: \(code)") }
                self = .conventionCreatedContent("\(remainder.prefix(upTo: dashIdx))")
            } else if code.hasPrefix("DDAL-DRW") || code.hasPrefix("DDEP-DRW") {
                self = .dreamsOfRedWizards
            } else if code.hasPrefix("DDAL-EB") {
                self = .oracleOfWar
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
