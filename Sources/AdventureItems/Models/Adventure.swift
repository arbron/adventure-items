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

    enum Source: CaseIterable, Hashable {
        case season(Int)
        case hardcover

        case dreamsOfRedWizards
        case embersOfTheLastWar
        case oracleOfWar

        case conventionCreatedContent(String?)

        init(_ code: String) {
            if let remainder = code.removePrefix("CCC-") {
                guard let dashIdx = remainder.firstIndex(of: "-") else { fatalError("Invalid CCC code: \(code)") }
                self = .conventionCreatedContent("\(remainder.prefix(upTo: dashIdx))")
            } else if code.hasPrefixes("DDAL-DRW", "DDEP-DRW") {
                self = .dreamsOfRedWizards
            } else if code.hasPrefixes("DDAL-ELW", "DDAL-WGE") {
                self = .embersOfTheLastWar
            } else if code.hasPrefix("DDAL-EB") {
                self = .oracleOfWar
            } else if code.hasPrefixes("DDAL-CGB", "DDAL-OPEN", "DDALCA") {
                self = .season(0)
            } else if let remainder = code.removePrefixes("DDAL", "DDEX", "DDEP") {
                guard let seasonNum = Adventure.formatter.number(from: "\(remainder.prefix(2))") else { fatalError("Invalid Season code: \(code)") }
                self = .season(seasonNum.intValue)
            } else if code.hasPrefix("DDHC") {
                self = .hardcover
            } else {
                fatalError("Invalid adventure code: \(code)")
            }
        }

        static var allCases: [Source] {
            var cases: [Source] = []
            for seasonNum in 1...10 {
                cases.append(.season(seasonNum))
            }
            cases.append(.season(0))
            cases.append(contentsOf: [
                .hardcover,
                .dreamsOfRedWizards,
                .embersOfTheLastWar,
                .oracleOfWar,
                .conventionCreatedContent(nil)
            ])
            return cases
        }

        var stringValue: String {
            switch self {
            case .season(0): return "Season Agnostic"
            case .season(let number): return "Season \(number)"
            case .hardcover: return "Hardcovers"
            case .dreamsOfRedWizards: return "Dreams of Red Wizards"
            case .embersOfTheLastWar: return "Embers of the Last War"
            case .oracleOfWar: return "Oracle of War"
            case .conventionCreatedContent: return "Convention Created Content"
            }
        }
    }
}
