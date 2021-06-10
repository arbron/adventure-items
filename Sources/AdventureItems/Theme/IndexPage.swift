//
//  IndexPage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

import Plot
import Publish


extension LeagueHTMLFactory {
    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                WrappedPage(for: context) {
                    IndexPageBody(index, for: context)
                }.convertToNode()
            )
        )
    }
}


struct IndexPageBody<S: Website>: Component {
    typealias SplitItems = [Adventure.Source: [Publish.Item<AdventureItemsSite>]]

    var index: Index
    var context: PublishingContext<S>
    var items: SplitItems = [:]

    init(_ index: Index, for context: PublishingContext<S>) {
        self.index = index
        self.context = context
        self.items = splitItemsIntoSections(context.sections.flatMap { $0.items })
    }

    @ComponentBuilder
    var body: Component {
        H1(index.title)
        Markdown(context.site.description).class("description")
        for category in Adventure.Source.allCases {
            if let categoryItems = items[category] {
                H2(category.localizedStringValue)
                AdventureList(items: categoryItems)
            }
        }
    }

    private func splitItemsIntoSections(_ items: [Publish.Item<S>]) -> SplitItems {
        var dictionary: SplitItems = .init()

        for item in items {
            guard let adventureItem = item as? Publish.Item<AdventureItemsSite>,
                  let adventure = adventureItem.metadata.adventure else { continue }
            var array = dictionary[adventure.source] ?? []
            array.append(adventureItem)
            dictionary[adventure.source] = array
        }

        return dictionary
    }
}
