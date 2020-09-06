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

    static func item(for adventure: Adventure) -> Self {
        var tags: Set<Tag> = []
        for item in adventure.items {
            tags.insert("items")
            tags.insert("rarity: \(item.rarity.rawValue)")
        }
        for spellbook in adventure.spellbooks {
            tags.insert("spellbooks")
            for spell in spellbook.spells {
                tags.insert("spell: \(spell.name)")
            }
        }
        if !adventure.storyAwards.isEmpty {
            tags.insert("story awards")
        }

        return Self(
            path: Path(adventure.code.lowercased()),
            sectionID: ASite.SectionID.adventures,
            metadata: ASite.ItemMetadata(),
            tags: Array(tags),
            content: Content(
                title: "\(adventure.code) - \(adventure.name)",
                body: Self.body(adventure)
            )
        )
    }

    private static func body(_ adventure: Adventure) -> Content.Body {
        .init(node:
            .section(
                .h1("\(adventure.name)"),
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
            .group(items.map { item in
                var itemEntry: [Node<HTML.BodyContext>] = [
                    "\(item.name)",
                    " ",
                    .em("\(item.rarity)")
                ]
                if let count = item.count {
                    itemEntry.insert("\(count) x ", at: 0)
                }
                
                return .li(.group(itemEntry))
            })
        )
    }

    private static func spellbookList(_ spellbooks: [Spellbook]) -> Node<HTML.BodyContext> {
        .ul(.group(
            spellbooks.map { spellbook in
                if let spells = ListFormatter().string(from: spellbook.spells.map { $0.name }) {
                    return .li(
                        .strong("\(spellbook.name): "),
                        "\(spells)"
                    )
                } else {
                    return .li(.strong("\(spellbook.name)"))
                }

            }
        ))
    }

    private static let parser = MarkdownParser()
    private static func storyAwardList(_ storyAwards: [StoryAward]) -> Node<HTML.BodyContext> {
        .group(
            storyAwards.map { award in
                .details(
                    .summary("\(award.name)"),
                    .raw("\(Self.parser.html(from: award.description))")
                )
            }
        )
    }
}
