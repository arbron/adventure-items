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
                Text("Adventure Seed: ").italic()
                Text(seed)
            }
        }
        if !adventure.description.isEmpty {
            Markdowned(adventure.description)
        }
//        if let series = adventure.series {
//            Paragraph(series.name)
//        }

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
            args.append((!adventure.isEpic ? "Adventure" : "Epic").localized())
        }
        if let tiers = tiersString {
            key += " for <Tier>"
            args.append(tiers)
        }

        return key.localizedAndFormatted(args)
    }

    var tiersString: String? {
        guard let tiers = adventure.tier else { return nil }

        if tiers.count == 4 {
            return "All Tiers".localized()
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.formattingContext = .listItem
        numberFormatter.numberStyle = .none // TODO: Maybe switch to ordinal format?
        let listFormatter = ListFormatter()
        listFormatter.itemFormatter = numberFormatter

        if let formattedTiers = listFormatter.string(from: tiers.map(\.rawValue)) {
            let key = "\(tiers.count == 1 ? "Tier" : "Tiers") <Tier List>" // TODO: Figure out how to do this localization properly
            return key.localizedAndFormatted(formattedTiers)
        }

        return nil
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

    static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "en_US")
        return f
    }
}


struct ItemsSection: Component {
    let items: [Item]
    
    init(_ items: [Item]) {
        self.items = items
    }

    @ComponentBuilder
    var body: Component {
        H2("Items") // TODO: Localize items header
        List(items) { item in
            ListItem {
                if let count = item.count {
                    Text("\(count) x ") // TODO: Localize item count
                }
                Span {
                    Text(item.name)
                }.class(item.illegal ? "illegal" : "")
                Text(" ")
                Text(
                    !item.illegal ? item.rarity.name : "Not AL Legal" // TODO: Localize not al legal
                ).italic().class("entry-label")
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
        H2("Spellbooks") // TODO: Localize spellbooks header
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
        H2(type == .default ? "Story Awards" : "Legacy Events") // TODO: Localize story awards header
        for award in storyAwards {
            Disclosure(summary: awardName(award), details: Markdowned(award.description))
                .class("story-award")
        }
    }

    @ComponentBuilder
    func awardName(_ award: StoryAward) -> Component {
        Text(award.name)
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
        if let potionText = "potion".counted(potionCount) {
            magicItemNames.append(potionText)
        }
        if let scrollText = "scroll".counted(scrollCount) {
            magicItemNames.append(scrollText)
        }
        for spellbook in adventure.spellbooks {
            tags.insert("spellbooks")
            for spell in spellbook.spells {
                tags.insert("spell: \(spell.name.lowercased())")
            }
        }
        if let spellbookText = "spellbook".counted(adventure.spellbooks.count) {
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
        if let otherText = "other item".counted(otherConsumableCount, singularArticle: "one") {
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

        return Self(
            path: Path(adventure.path),
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
                date: adventure.released ?? Date.distantPast
            )
        )
    }
}
