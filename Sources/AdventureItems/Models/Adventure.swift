//
//  Adventure.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import AdventureUtils
import Foundation


struct Adventure: Codable, Hashable {
    var code: String
    var name: String
    @DecodableDefault.EmptyString var description: String
    @DecodableDefault.EmptyString var contentWarning: String

    var adventureSeed: String?

    var released: Date?
    var creator: String?
    var url: URL?
    @SingleValueCollection var tier: [Tier]?
    var length: Length?
    @SingleValueCollection var apl: [Int]?

    @DecodableDefault.EmptyList var credits: [Credit]

    @DecodableDefault.False var incomplete: Bool

    @DecodableDefault.EmptyList var items: [Item]
    @DecodableDefault.EmptyList var spellbooks: [Spellbook]
    @DecodableDefault.EmptyList var storyAwards: [StoryAward]

    @DecodableDefault.EmptyList var missing: [String]


    // MARK: Not Included in Data Files
    var series: Series?
}

extension Adventure {
    var source: Source { Source(code) }
    var isEpic: Bool { code.hasPrefix("DDEP") || code.hasPrefix("DDAL-EBEP") || code.hasPrefix("DDAL-DRWEP") || code.hasPrefix("RMH-EP") }
    var storyAwardName: String {
        let string = NSLocalizedString(storyAwardType.rawValue, bundle: Bundle.module, comment: "")
        return String.localizedStringWithFormat(string, 1)
    }
    var storyAwardType: StoryAwardType {
        switch source {
        case .dreamsOfRedWizards, .oracleOfWar, .ravenloftMistHunters:
            if code != "DDAL-DRW-01" && code != "DDAL-DRW-02" && code != "DDAL-DRW-03" {
                return .legacyEvent
            }
            fallthrough
        default: return .default
        }
    }

    var slug: String {
        code.lowercased().replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: #"""#, with: "")
    }

    var path: String {
        "/adventures/\(slug)"
    }

    enum StoryAwardType: String {
        case `default` = "story-award"
        case legacyEvent = "legacy-event"
    }

    enum Tier: Int, Codable, Hashable {
        case one = 1, two, three, four
    }
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

        case authorOnly
        case introAdventure

        // Masters
        case dreamsOfRedWizards

        // Alternative
        case embersOfTheLastWar
        case oracleOfWar
        case ravenloftMistHunters

        case conventionCreatedContent
        case dungeonCraft(String)

        init(_ code: String) {
            if code.hasPrefix("CCC-") {
                self = .conventionCreatedContent
            } else if code.hasPrefix("DC-PoA") {
                self = .dungeonCraft("PoA")
            } else if code.hasPrefixes("DDAL-DRW", "DDEP-DRW") {
                self = .dreamsOfRedWizards
            } else if code.hasPrefixes("DDAL-ELW", "DDAL-WGE") {
                self = .embersOfTheLastWar
            } else if code.hasPrefix("DDAL-EB") {
                self = .oracleOfWar
            } else if code.hasPrefix("WBW-DC") {
                self = .dungeonCraft("WBW")
            } else if code.hasPrefix("WBW") {
                self = .season(11)
            } else if code.hasPrefix("RMH") {
                self = .ravenloftMistHunters
            } else if code.hasPrefixes("DDAL-CGB", "DDAL-OPEN", "DDALCA") {
                self = .season(0)
            } else if let remainder = code.removePrefixes("DDAL", "DDEX", "DDEP") {
                guard let seasonNum = Adventure.formatter.number(from: "\(remainder.prefix(2))") else { fatalError("Invalid Season code: \(code)") }
                self = .season(seasonNum.intValue)
            } else if code.hasPrefix("DDHC") {
                self = .hardcover
            } else if code.hasPrefix("DDAO") {
                self = .authorOnly
            } else if code.hasPrefix("DDIA") || code.hasPrefix("DDLE") {
                self = .introAdventure
            } else {
                fatalError("Invalid adventure code: \(code)")
            }
        }

        static var allCases: [Source] {
            var cases: [Source] = []
            for seasonNum in 1...11 {
                cases.append(.season(seasonNum))
            }
            cases.append(.season(0))
            cases.append(contentsOf: [
                .authorOnly,
                .introAdventure,
                .hardcover,
                .dreamsOfRedWizards,
                .embersOfTheLastWar,
                .oracleOfWar,
                .ravenloftMistHunters,
                .conventionCreatedContent,
                .dungeonCraft("PoA"),
                .dungeonCraft("WBW"),
            ])
            return cases
        }

        var localizedStringValue: String {
            if case let Source.season(number) = self, number > 0 {
                let string = NSLocalizedString("source-season(#)", bundle: Bundle.module, comment: "Adventure source name for \(self)")
                return String.localizedStringWithFormat(string, number)
            }
            if case let Source.dungeonCraft(name) = self {
                return "source-dungeoncraft(\(name))".localized(comment: "Adventure source name for \(self)")
            }
            let key = "source-\(self)"
            return NSLocalizedString(key, bundle: Bundle.module, comment: "Adventure source name for \(self)")
        }

        var shortLocalizedStringValue: String {
            switch self {
            case .dungeonCraft(_):
                return "source-dungeoncraft".localized(comment: "Short adventure source name for \(self)")
            default:
                return self.localizedStringValue
            }
        }
    }
}
