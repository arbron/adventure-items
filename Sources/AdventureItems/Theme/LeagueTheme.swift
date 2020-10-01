//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Publish
import Plot
import Ink

extension Theme where Site == AdventureItemsSite {
    static var league: Self {
        Theme(
            htmlFactory: LeagueHTMLFactory(),
            resourcePaths: ["Resources/LeagueTheme/styles.css"]
        )
    }
}

private struct LeagueHTMLFactory: HTMLFactory {
    typealias Site = AdventureItemsSite

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        let splitItems = splitItemsIntoSections(context.sections.flatMap { $0.items })

        return HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(.text(index.title)),
                    .p(
                        .class("description"),
                        .text(context.site.description)
                    ),
                    .forEach(Adventure.Source.allCases, { category in
                        .unwrap(splitItems[category]) { items in
                            .group(
                                .h2(.text(category.stringValue)),
                                .adventureList(for: items)
                            )
                        }
                    })
                ),
                .footer(for: context.site)
            )
        )
    }

    private func splitItemsIntoSections(_ items: [Publish.Item<Site>]) -> [Adventure.Source: [Publish.Item<Site>]] {
        var dictionary: [Adventure.Source: [Publish.Item<Site>]] = [:]

        for item in items {
            switch item.metadata.adventure.source {
            case .conventionCreatedContent:
                var array = dictionary[.conventionCreatedContent] ?? []
                array.append(item)
                dictionary[.conventionCreatedContent] = array
            default:
                var array = dictionary[item.metadata.adventure.source] ?? []
                array.append(item)
                dictionary[item.metadata.adventure.source] = array
            }
        }

        return dictionary
    }

    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .adventureList(for: section.items)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeItemHTML(for item: Publish.Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        ),
                        .span("Tagged with: "),
                        .tagList(for: item, on: context.site)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .groupedTagsList(for: page.tags.sorted(), on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .adventureList(
                        for: context.items(taggedWith: page.tag, sortedBy: \.title, order: .ascending)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    static var parser = MarkdownParser()

    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func header<T: Website>(for context: PublishingContext<T>, selectedSection: T.SectionID?) -> Node {
        let sectionIDs = T.SectionID.allCases

        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(sectionIDs.count > 1,
                    .nav(
                        .ul(.forEach(sectionIDs) { section in
                            .li(.a(
                                .class(section == selectedSection ? "selected" : ""),
                                .href(context.sections[section].path),
                                .text(context.sections[section].title)
                            ))
                        })
                    )
                )
            )
        )
    }

    static func adventureList(for items: [Publish.Item<AdventureItemsSite>]) -> Node {
        .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(
                        .a(.href(item.path), .text(item.metadata.adventure.name)),
                        .em(.class("adventure-code"), .text(item.metadata.adventure.code))
                    ),
                    .raw(Self.parser.html(from: item.description))
                ))
            }
        )
    }

    static func tagList<T: Website>(for item: Publish.Item<T>, on site: T) -> Node {
        return .ul(
            .class("tag-list"),
            .forEach(item.tags) { tag in
                .li(
                    .unwrap(tag.tagClass) { .class($0) },
                    .a(.href(site.path(for: tag)), .text(tag.string))
                )
            }
        )
    }

    static func groupedTagsList<T: Website>(for tags: [Tag], on site: T) -> Node {
        var adventureTags: [(Tag, String)] = []
        var creatorTags: [(Tag, String)] = []
        var rarityTags: [(Tag, String)] = []
        var spellTags: [(Tag, String)] = []
        var otherTags: [(Tag, String)] = []
        for tag in tags {
            if let adventure = tag.string.removePrefix("adventure: ") {
                adventureTags.append((tag, "\(adventure)"))
            } else if let creator = tag.string.removePrefix("creator: ") {
                creatorTags.append((tag, "\(creator)"))
            } else if let rarity = tag.string.removePrefix("rarity: ") {
                rarityTags.append((tag, "\(rarity)"))
            } else if let spell = tag.string.removePrefix("spell: ") {
                spellTags.append((tag, "\(spell)"))
            } else {
                otherTags.append((tag, tag.string))
            }
        }

        func tagSection(name: String, tags: [(Tag, String)]) -> Node {
            .if(!tags.isEmpty, .group(
                .h1(.text(name)),
                .ul(
                    .class("all-tags \(tags.first?.0.tagClass ?? "")"),
                    .forEach(tags) { tag in
                        .li(
                            .class("tag"),
                            .a(.href(site.path(for: tag.0)), .text(tag.1))
                        )
                    }
                ),
                .br()
            ))
        }

        return .group(
            tagSection(name: "Adventures", tags: adventureTags),
            tagSection(name: "Reward Categories", tags: otherTags),
            tagSection(name: "Items by Rarity", tags: rarityTags),
            tagSection(name: "Spells", tags: spellTags),
            tagSection(name: "Creators", tags: creatorTags)
        )
    }

    static func footer<T: Website>(for site: T) -> Node {
        .footer(
            .p(
                .text("Created by Jeff Hitchcock"),
                .text(" | "),
                .a(.href("https://twitter.com/arbron"), .text("Twitter")),
                .text(" | "),
                .a(.href("https://arbron.space"), .text("Tumblr")),
                .text(" | "),
                .a(.href("https://moviemaps.org"), .text("MovieMaps"))
            ),
            .p(
                .text("Generated using "),
                .a(.href("https://github.com/johnsundell/publish"), .text("Publish")),
                .text(". Site source available on "),
                .a(.href("https://github.com/arbron/adventure-items/"), .text("GitHub")),
                .text(".")
            )
        )
    }
}
