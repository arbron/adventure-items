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

extension Publish.Item where Site == AdventureItemsSite {
    fileprivate typealias ASite = AdventureItemsSite

    private static let parser = MarkdownParser()

    static func item(for adventure: Adventure) -> Self {
        var magicItemNames: [String] = []
        var potionCount = 0
        var scrollCount = 0

        var tags: Set<Tag> = []
        for item in adventure.items {
            if !item.consumable {
                tags.insert("items")
                tags.insert("rarity: \(item.rarity.name)")
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
            if let spellbookText = "spellbook".counted(adventure.spellbooks.count) {
                magicItemNames.append(spellbookText)
            }
        }
        if !adventure.storyAwards.isEmpty {
            tags.insert("story awards")
            if let storyAwardText = "story award".counted(adventure.storyAwards.count) {
                magicItemNames.append(storyAwardText)
            }
        }

        return Self(
            path: Path(adventure.code.lowercased()),
            sectionID: ASite.SectionID.adventures,
            metadata: ASite.ItemMetadata(),
            tags: Array(tags).sorted(),
            content: Content(
                title: "\(adventure.code) - \(adventure.name)",
                description: ListFormatter().string(from: magicItemNames) ?? "",
                body: Self.body(adventure)
            )
        )
    }

    private static func body(_ adventure: Adventure) -> Content.Body {
        .init(node:
            .section(
                .h1("\(adventure.name)"),
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

    private static func itemList(_ items: [Item]) -> Node<HTML.BodyContext> {
        .ul(
            .forEach(items) { item in
                var itemEntry: [Node<HTML.BodyContext>] = [
                    "\(item.name)",
                    " ",
                    .em("\(item.rarity.name)")
                ]
                if let count = item.count {
                    itemEntry.insert("\(count) x ", at: 0)
                }
                
                return .li(.group(itemEntry))
            }
        )
    }

    private static func spellbookList(_ spellbooks: [Spellbook]) -> Node<HTML.BodyContext> {
        .ul(
            .forEach(spellbooks) { spellbook in
                if let spells = ListFormatter().string(from: spellbook.spells.map { $0.name }) {
                    return .li(
                        .strong("\(spellbook.name): "),
                        "\(spells)"
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
                .summary("\(award.name)"),
                .raw("\(Self.parser.html(from: award.description))")
            )
        }
    }
}

fileprivate extension String {
    func counted(_ count: Int, plural: String? = nil) -> String? {
        guard count > 0 else { return nil }
        if count == 1 { return "a \(self)" }
        return "\(count) \(plural ?? "\(self)s")"
    }
}
