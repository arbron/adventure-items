//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Publish
import Plot

public extension Theme {
    static var league: Self {
        Theme(
            htmlFactory: LeagueHTMLFactory(),
            resourcePaths: ["Resources/LeagueTheme/styles.css"]
        )
    }
}

private struct LeagueHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
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
                    .itemList(for: context.allItems(sortedBy: \.title, order: .ascending), on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .itemList(for: section.items, on: context.site)
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
                    .itemList(
                        for: context.items(taggedWith: page.tag, sortedBy: \.date, order: .descending),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
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

    static func itemList<T: Website>(for items: [Publish.Item<T>], on site: T) -> Node {
        .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(.a(.href(item.path), .text(item.title))),
//                    .tagList(for: item, on: site),
                    .p(.text(item.description))
                ))
            }
        )
    }

    static func tagList<T: Website>(for item: Publish.Item<T>, on site: T) -> Node {
        .ul(
            .class("tag-list"),
            .forEach(item.tags) { tag in
                .li(.a(.href(site.path(for: tag)), .text(tag.string)))
            }
        )
    }

    static func groupedTagsList<T: Website>(for tags: [Tag], on site: T) -> Node {
        var rarityTags: [(Tag, String)] = []
        var spellTags: [(Tag, String)] = []
        var otherTags: [(Tag, String)] = []
        for tag in tags {
            if let rarity = tag.string.removePrefix("rarity: ") {
                rarityTags.append((tag, "\(rarity)"))
            } else if let spell = tag.string.removePrefix("spell: ") {
                spellTags.append((tag, "\(spell)"))
            } else {
                otherTags.append((tag, tag.string))
            }
        }

        func tagSection(name: String, tags: [(Tag, String)]) -> Node {
            .group(
                .h1(.text(name)),
                .ul(
                    .class("all-tags"),
                    .forEach(tags) { tag in
                        .li(
                            .class("tag"),
                            .a(.href(site.path(for: tag.0)), .text(tag.1))
                        )
                    }
                ),
                .br()
            )
        }

        return .group(
            tagSection(name: "Categories", tags: otherTags),
            tagSection(name: "Items by Rarity", tags: rarityTags),
            tagSection(name: "Spells", tags: spellTags)
        )
    }

    static func footer<T: Website>(for site: T) -> Node {
        .footer(
            .p(
                .text("Generated using "),
                .a(.href("https://github.com/johnsundell/publish"), .text("Publish"))
            ),
            .p(
                .a(.href("/feed.rss"), .text("RSS feed"))
            )
        )
    }
}
