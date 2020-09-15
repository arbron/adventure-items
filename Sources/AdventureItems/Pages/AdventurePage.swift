//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-06.
//

import Foundation
import Plot
import Publish
import Ink

extension PublishingStep where Site == AdventureItemsSite {
    static func addAdventures(
        _ adventures: [Adventure], removeIncomplete: Bool = false, removeDated: Bool = false
    ) -> Self {
        step(named: "Add adventures") { context in
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

    private static let parser = MarkdownParser()
    private static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "en_US")
        return f
    }

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
            if let storyAwardText = "story award".counted(adventure.storyAwards.count) {
                magicItemNames.append(storyAwardText)
            }
        }
        if let otherText = "other item".counted(otherConsumableCount, singularArticle: "one") {
            magicItemNames.append(otherText)
        }

        tags.insert("adventure: \(adventure.source.stringValue.lowercased())")
        _ = adventure.tier.map { $0.map { tags.insert("adventure: tier \($0.rawValue)") } }
        if adventure.isEpic {
            tags.insert("adventure: epic")
        }
        if let creator = adventure.creator {
            tags.insert("creator: \(creator.lowercased())")
        }

        let description = adventure.incomplete ? "*(incomplete)*" : ListFormatter().string(from: magicItemNames) ?? ""

        return Self(
            path: Path(adventure.code.lowercased()),
            sectionID: ASite.SectionID.adventures,
            metadata: ASite.ItemMetadata(
                adventure: adventure
            ),
            tags: Array(tags).sorted(),
            content: Content(
                title: "\(adventure.code) - \(adventure.name)",
                description: description,
                body: Self.body(adventure),
                date: adventure.released ?? Date()
            )
        )
    }

    private static func body(_ adventure: Adventure) -> Content.Body {
        .init(node:
            .section(
                .h1(.text(adventure.name)),
                Self.subheading(adventure),
                .if(!adventure.description.isEmpty, .raw("\(parser.html(from: adventure.description))")),
                .if(!adventure.items.isEmpty, .group([
                    .h2("Items"),
                    .p(Self.itemList(adventure.items))
                ])),
                .if(!adventure.spellbooks.isEmpty, .group([
                    .h2("Spellbooks"),
                    .p(Self.spellbookList(adventure.spellbooks))
                ])),
                .if(!adventure.storyAwards.isEmpty, .group([
                    .h2("Story Awards"),
                    Self.storyAwardList(adventure.storyAwards)
                ]))
            )
        )
    }
    
    private static func subheading(_ adventure: Adventure) -> Node<HTML.BodyContext> {
        .group(
            .h3(
                .text(adventure.source.stringValue),
                " ",
                .if(adventure.source != .conventionCreatedContent,
                    .if(!adventure.isEpic, .text("Adventure"), else: .text("Epic"))
                ),
                .unwrap(adventure.tier) { tiers in
                    Self.subheadingTiers(tiers)
                },
                .if(adventure.released != nil || adventure.creator != nil,
                    .em(
                        .class("release"),
                        Self.subheadingRelease(adventure)
                    )
                )
            )
        )
    }

    private static func subheadingTiers(_ tiers: [Adventure.Tier]) -> Node<HTML.BodyContext> {
        .if(tiers.count == 4,
            .text(" for All Tiers"),
            else: .unwrap(ListFormatter().string(from: tiers.map(\.rawValue))) {
                .group(
                    " for Tier",
                    .if(tiers.count > 1, "s"),
                    " ",
                    .text($0)
                )
            }
        )
    }

    private static func subheadingRelease(_ adventure: Adventure) -> Node<HTML.BodyContext> {
        .group(
            " Released ",
            .unwrap(adventure.creator) { creator in
                .text(" by \(creator)")
            },
            .unwrap(adventure.released) { date in
                .text(" on \(Self.dateFormatter.string(from: date))")
            }
        )
    }

    private static func itemList(_ items: [Item]) -> Node<HTML.BodyContext> {
        .ul(
            .forEach(items) { item in
                .li(
                    .unwrap(item.count) { count in
                        .text("\(count) x ")
                    },
                    .span(
                        .if(item.illegal, .class("illegal")),
                        .text(item.name)
                    ),
                    .em(
                        .class("entry-label"),
                        .if(!item.illegal,
                            .text(item.rarity.name),
                            else: .text("Not AL Legal")
                        )
                    )
                )
            }
        )
    }

    private static func spellbookList(_ spellbooks: [Spellbook]) -> Node<HTML.BodyContext> {
        .ul(
            .forEach(spellbooks) { spellbook in
                if let spells = ListFormatter().string(from: spellbook.spells.map { $0.name }) {
                    return .li(
                        .strong("\(spellbook.name): "),
                        "\(spells)",
                        .if(spellbook.note != "",
                            .em(
                                .class("entry-label"),
                                .text(spellbook.note)
                            )
                        )
                    )
                } else {
                    return .li(.strong("\(spellbook.name)"))
                }

            }
        )
    }

    private static func storyAwardList(_ storyAwards: [StoryAward]) -> Node<HTML.BodyContext> {
        .forEach(storyAwards) { award in
            .details(
                .class("story-award"),
                .summary(
                    .text(award.name),
                    .if(award.downtime,
                        .em(
                            .class("entry-label"),
                            .text("Downtime Activity")
                        )
                    )
                ),
                .raw("\(Self.parser.html(from: award.description))")
            )
        }
    }
}
