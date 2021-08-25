//
//  AdventurePage.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-06.
//

import AdventureUtils
import Foundation
import Plot
import Publish
import Ink


fileprivate let parser = MarkdownParser()


struct AdventurePage: Component {
    let adventure: Adventure

    @ComponentBuilder
    var body: Component {
        H1(adventure.name)
        subHeading

        if let seed = adventure.adventureSeed {
            Paragraph {
                Text("Adventure Seed: ").italic() // TODO: Localize adventure seed prefix
                Text(seed)
            }
        }
        if !adventure.description.isEmpty {
            Markdowned(adventure.description)
        }
        if let series = seriesString {
            Markdowned(series)
        }
        if let url = adventure.url {
            Markdown("Available on [Dungeon Masters Guild](\(url)).")
        }

        if !adventure.credits.isEmpty {
            CreditsSection(adventure.credits)
        }
        if !adventure.items.isEmpty {
            ItemsSection(adventure.items)
        }
        if !adventure.spellbooks.isEmpty {
            SpellbooksSection(adventure.spellbooks)
        }
        if !adventure.storyAwards.isEmpty {
            StoryAwardsSection(adventure.storyAwards, type: adventure.storyAwardType)
        }
    }

    @ComponentBuilder
    var subHeading: Component {
        H3 {
            Text(subheadingDescription)
            if let released = releaseString {
                Text(released)
                    .italic()
                    .class("release")
            }
        }
    }

    var subheadingDescription: String {
        var key = "<Source>"
        var args: [CVarArg] = [adventure.source.localizedStringValue]

        if adventure.source != .conventionCreatedContent {
            key += " <Type>"
            switch adventure.length {
            case .multi:
                args.append((!adventure.isEpic ? "AdventurePlural" : "EpicPlural").localized())
            default:
                args.append((!adventure.isEpic ? "Adventure" : "Epic").localized())
            }
        }
        if let tiers = adventure.tier?.localizedString() {
            key += " for <Tier>"
            args.append(tiers)
        }

        let formatted = key.localizedAndFormatted(args)
        switch adventure.length {
        case .flat(let length):
            return "<Length Single>".localizedAndFormatted("\(length)", formatted)
        case .range(let min, let max):
            return "<Length Range>".localizedAndFormatted("\(min)", "\(max)", formatted)
        case .multi(let count, let length):
            return "<Length Multi>".localizedAndFormatted(Self.countFormatter.string(from: NSNumber(integerLiteral: count))!, "\(length)", formatted)
        default:
            return formatted
        }
    }

    var releaseString: String? {
        guard adventure.creator != nil || adventure.released != nil else { return nil }

        var key = "Released"
        var args: [CVarArg] = []
        if let creator = adventure.creator {
            key += " by <Creator>"
            args.append(creator)
        }
        if let date = adventure.released {
            key += " on <Date>"
            args.append(Self.dateFormatter.string(from: date))
        }
        return key.localizedAndFormatted(args)
    }

    var seriesString: String? {
        guard let series = adventure.series,
              let seriesInfo = series.adventures.first(where: { $0.code == adventure.code }) else { return nil }

        var key: String
        var args: [CVarArg] = []
        if let position = seriesInfo.position,
           let formattedPosition = Self.seriesNumberFormatter.string(from: NSNumber(value: position)) {
            key = "adventurePage.orderedSeriesMember"
            args.append(formattedPosition)
        } else {
            key = "adventurePage.unorderedSeriesMember"
        }
        if !series.includesArticle { key = "\(key)WithArticle" }
        args.append("*[\(series.name)](\(series.path))*")

        return key.localizedAndFormatted(args)
    }

    static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "en_US")
        return f
    }

    static var seriesNumberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .spellOut
        f.formattingContext = .standalone
        return f
    }

    static var countFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .spellOut
        f.formattingContext = .beginningOfSentence
        return f
    }
}


struct CreditsSection: Component {
    let credits: [Credit]

    init(_ credits: [Credit]) {
        self.credits = credits
    }

    @ComponentBuilder
    var body: Component {
        H2("adventurePage.creditHeader".localized())
        List(credits) { credit in
            ListItem {
                Text(credit.name)
                Text(credit.role).italic().bold()
            }
        }.class("credits")
    }
}


struct ItemsSection: Component {
    let items: [Item]
    
    init(_ items: [Item]) {
        self.items = items
    }

    @ComponentBuilder
    var body: Component {
        H2("adventurePage.itemHeader".localized())
        List(items) { item in
            ListItem {
                if let count = item.count {
                    Text("\(count) x ") // TODO: Localize item count
                }
                Span {
                    Text(item.name)
                }.class(item.illegal ? "illegal" : "")
                Text(" ")
                Text(!item.illegal ? item.rarity.name : "item.notAlLegal".localized())
                    .italic()
                    .class("entry-label")
            }
        }
    }
}


struct SpellbooksSection: Component {
    static let formatter = ListFormatter()

    let spellbooks: [Spellbook]
    
    init(_ spellbooks: [Spellbook]) {
        self.spellbooks = spellbooks
    }

    @ComponentBuilder
    var body: Component {
        H2("adventurePage.spellbookHeader".localized())
        List(spellbooks) { spellbook in
            ListItem {
                if let spells = formattedSpells(spellbook) {
                    Text("\(spellbook.name): ").bold()
                    Text(spells) // TODO: Display spells better
                    if spellbook.note != "" {
                        Markdowned(spellbook.note)
                            .italic()
                            .class("entry-label")
                    }
                } else {
                    Text(spellbook.name).bold()
                }
            }
        }
    }

    func formattedSpells(_ spellbook: Spellbook) -> String? {
        SpellbooksSection.formatter.string(from: spellbook.spells.map { $0.name })
    }
}


struct StoryAwardsSection: Component {
    let storyAwards: [StoryAward]
    let type: Adventure.StoryAwardType

    init(_ storyAwards: [StoryAward], type: Adventure.StoryAwardType = .default) {
        self.storyAwards = storyAwards
        self.type = type
    }

    @ComponentBuilder
    var body: Component {
        H2("adventurePage.\(type.rawValue)Header".localized())
        for award in storyAwards {
            Disclosure(summary: awardName(award), details: Markdowned(award.description))
                .class("story-award")
        }
    }

    @ComponentBuilder
    func awardName(_ award: StoryAward) -> Component {
        Text(award.name) // TODO: Fix extra space being added around story awards with labels
        if let type = award.type {
            Text(" \(type.name)")
                .italic()
                .class("entry-label")
        }
    }
}



// MARK: - Building Steps

extension PublishingStep where Site == AdventureItemsSite {
    static func addAdventures(
        _ adventures: [Adventure], removeIncomplete: Bool = false, removeDated: Bool = false
    ) -> Self {
        step(named: "Add Adventures") { context in
            for adventure in adventures {
                guard !removeDated || adventure.released == nil else { continue }
                guard !removeIncomplete || !adventure.incomplete else { continue }
                context.addItem(.item(for: adventure))
            }
        }
    }
}

extension Publish.Item where Site == AdventureItemsSite {
    fileprivate typealias ASite = AdventureItemsSite

    static func item(for adventure: Adventure) -> Self {
        var magicItemNames: [String] = []
        var potionCount = 0
        var scrollCount = 0
        var otherConsumableCount = 0

        var tags: Set<Tag> = []
        for item in adventure.items {
            if item.illegal {
                tags.insert("illegal items")
            } else if !item.consumable {
                tags.insert("items")
                tags.insert("rarity: \(item.rarity.name.lowercased())")
                magicItemNames.append(item.name)
            } else if item.name.hasPrefix("Potion") {
                tags.insert("potions")
                potionCount += item.count ?? 1
            } else if item.name.hasPrefix("Scroll") || item.name.hasPrefix("Spell Scroll") {
                tags.insert("scrolls")
                scrollCount += item.count ?? 1
                if let spellName = item.name.removePrefix("Spell Scroll of ") {
                    tags.insert("spell: \(spellName.lowercased())")
                }
            } else {
                otherConsumableCount += item.count ?? 1
            }
        }
        if let potionText = "potion".counted(potionCount) { // TODO: potion spellbook list entry
            magicItemNames.append(potionText)
        }
        if let scrollText = "scroll".counted(scrollCount) { // TODO: Localize scroll list entry
            magicItemNames.append(scrollText)
        }
        for spellbook in adventure.spellbooks {
            tags.insert("spellbooks")
            for spell in spellbook.spells {
                tags.insert("spell: \(spell.name.lowercased())")
            }
        }
        if let spellbookText = "spellbook".counted(adventure.spellbooks.count) { // TODO: Localize spellbook list entry
            magicItemNames.append(spellbookText)
        }
        if !adventure.storyAwards.isEmpty {
            tags.insert("story awards")
            let string = NSLocalizedString("\(adventure.storyAwardType.rawValue)-numbered", bundle: Bundle.module, comment: "")
            magicItemNames.append(String.localizedStringWithFormat(string, adventure.storyAwards.count))
            for award in adventure.storyAwards {
                guard let type = award.type else { continue }
                tags.insert("\(type.plural)")
            }
        }
        if let otherText = "other item".counted(otherConsumableCount, singularArticle: "one") { // TODO: Localize other items list entry
            magicItemNames.append(otherText)
        }

        tags.insert("adventure: \(adventure.source.localizedStringValue.lowercased())")
        _ = adventure.tier.map { $0.map { tags.insert("adventure: tier \($0.rawValue)") } }
        if adventure.isEpic {
            tags.insert("adventure: epic")
        }
        if let creator = adventure.creator {
            tags.insert("creator: \(creator.lowercased())")
        }

        let description = adventure.incomplete ? "*(incomplete)*" : ListFormatter().string(from: magicItemNames) ?? ""

        var releaseDate = adventure.released ?? Date.distantPast
        if releaseDate > Date() {
            releaseDate = Date.distantPast
        }

        return Self(
            path: Path(adventure.slug),
            sectionID: ASite.SectionID.adventures,
            metadata: ASite.ItemMetadata(
                adventure: adventure
            ),
            tags: Array(tags).sorted(),
            content: Content(
                title: "\(adventure.code) - \(adventure.name)",
                description: description,
                body: .init(indentation: AdventureItemsSite.indentationMode) {
                    AdventurePage(adventure: adventure)
                },
                date: releaseDate
            )
        )
    }
}
