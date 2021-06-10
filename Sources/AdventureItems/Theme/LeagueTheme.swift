//
//  LeagueTheme.swift
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

struct LeagueHTMLFactory: HTMLFactory {
    typealias Site = AdventureItemsSite

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        let splitItems = splitItemsIntoSections(context.sections.flatMap { $0.items })

        return HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                PageHeader(for: context).convertToNode(),
                .wrapper(
                    .h1(.text(index.title)),
                    .p(
                        .class("description"),
                        .text(context.site.description)
                    ),
                    .forEach(Adventure.Source.allCases, { category in
                        .unwrap(splitItems[category]) { items in
                            .group(
                                .h2(.text(category.localizedStringValue)),
                                .adventureList(for: items)
                            )
                        }
                    })
                ),
                PageFooter().convertToNode()
            )
        )
    }

    private func splitItemsIntoSections(_ items: [Publish.Item<Site>]) -> [Adventure.Source: [Publish.Item<Site>]] {
        var dictionary: [Adventure.Source: [Publish.Item<Site>]] = [:]

        for item in items {
            guard let adventure = item.metadata.adventure else { continue }
            switch adventure.source {
            case .conventionCreatedContent:
                var array = dictionary[.conventionCreatedContent] ?? []
                array.append(item)
                dictionary[.conventionCreatedContent] = array
            default:
                var array = dictionary[adventure.source] ?? []
                array.append(item)
                dictionary[adventure.source] = array
            }
        }

        return dictionary
    }

    func makeItemHTML(for item: Publish.Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                PageHeader(for: context, section: item.sectionID).convertToNode(),
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
                PageFooter().convertToNode()
            )
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                PageHeader(for: context).convertToNode(),
                .wrapper(
                    .groupedTagsList(for: page.tags.sorted(), on: context.site)
                ),
                PageFooter().convertToNode()
            )
        )
    }
}


struct AdventureList<S: Website>: Component {
    var items: [Publish.Item<S>]

    var body: Component {
        List(items, content: listEntry).class("item-list")
    }

    @ComponentBuilder
    func listEntry(_ item: Publish.Item<S>) -> Component {
        Article {
            if let adventureItem = item as? Publish.Item<AdventureItemsSite>,
               let adventure = adventureItem.metadata.adventure {
                H1 {
                    Link(adventure.name, url: item.path.absoluteString)
                    Text(adventure.code).italic().class("adventure-code")
                }
            } else if let adventureItem = item as? Publish.Item<AdventureItemsSite>,
                      let series = adventureItem.metadata.series {
                H1 {
                    Link(series.name, url: item.path.absoluteString)
                    Text("Series").italic().class("adventure-code") // TODO: Localize based on series type
                }
            } else {
                H1 {
                    Link(item.title, url: item.path.absoluteString)
                }
            }
            Markdown(item.description)
        }
    }
}


struct Wrapper: Component {
    private var node: Node<HTML.BodyContext>

    init(@ComponentBuilder contents: () -> Component) {
        self.node = contents().convertToNode()
    }

    init(_ contents: Component) {
        self.node = contents.convertToNode()
    }

    var body: Component {
        Node<HTML.BodyContext>.div(
            .class("wrapper"),
            node
        )
    }
}


struct WrappedPage<S: Website>: Component {
    var context: PublishingContext<S>
    var contents: Component

    init(for context: PublishingContext<S>, @ComponentBuilder _ contents: () -> Component) {
        self.context = context
        self.contents = contents()
    }

    @ComponentBuilder
    var body: Component {
        PageHeader(for: context)
        Wrapper(contents)
        PageFooter()
    }
}


private extension Node where Context == HTML.BodyContext {
    static var parser = MarkdownParser()

    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func adventureList(for items: [Publish.Item<AdventureItemsSite>]) -> Node {
        .ul(
            .class("item-list"),
            .forEach(items) { item in
                .unwrap(item.metadata.adventure) { adventure in
                    .li(.article(
                        .h1(
                            .a(.href(item.path), .text(adventure.name)),
                            .em(.class("adventure-code"), .text(adventure.code))
                        ),
                        .raw(Self.parser.html(from: item.description))
                    ))
                }
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
}


struct PageHeader<S: Website>: Component {
    let context: PublishingContext<S>
    let selectedSection: S.SectionID?

    init(for context: PublishingContext<S>, section: S.SectionID? = nil) {
        self.context = context
        self.selectedSection = section
    }

    var body: Component {
        Header {
            Wrapper {
                Link(context.site.name, url: "/")
                    .class("site-name")
                // TODO: Add section links
//                if (S.SectionID.allCases.count > 1) {
//                    Navigation {
//                        List(S.SectionID.allCases, content: { section
//                            Link(context.sections[section].title, url: context.sections[section].path)
//                                .class(section == selectedSection ? "selected" : "")
//                        })
//                    }
//                }
//                .if(sectionIDs.count > 1,
//                    .nav(
//                        .ul(.forEach(sectionIDs) { section in
//                            .li(.a(
//                                .class(section == selectedSection ? "selected" : ""),
//                                .href(context.sections[section].path),
//                                .text(context.sections[section].title)
//                            ))
//                        })
//                    )
//                )
            }
        }
    }
}


struct PageFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("footer.createdBy".localized())
                Text(" | ")
                Link("Twitter", url: "https://twitter.com/arbron")
                Text(" | ")
                Link("Tumblr", url: "https://arbron.space")
                Text(" | ")
                Link("MovieMaps", url: "https://moviemaps.org")
            }
            Markdown(
                "footer.generatedUsing".localizedAndFormatted("[Publish](https://github.com/johnsundell/publish)") + " " +
                "footer.siteSource".localizedAndFormatted("[GitHub](https://github.com/arbron/adventure-items/)")
            )
        }
    }
}

