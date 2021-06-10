//
//  TagDetailsPage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

import Plot
import Publish


extension LeagueHTMLFactory {
    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                WrappedPage(for: context) {
                    TagDetailsPageBody(page: page, for: context)
                }.convertToNode()
            )
        )
    }
}


struct TagDetailsPageBody<S: Website>: Component {
    var page: TagDetailsPage
    var context: PublishingContext<S>

    init(page: TagDetailsPage, for context: PublishingContext<S>) {
        self.page = page
        self.context = context
    }

    @ComponentBuilder
    var body: Component {
        H1 {
            Text("Tagged with ") // TODO: Localize Tagged With
            Text(page.tag.string).class("tag") // TODO: Figure out why this class isn't being applied
        }
        Link("Browse all tags".localized(), url: context.site.tagListPath.absoluteString)
            .class("browse-all")
        AdventureList(items: context.items(taggedWith: page.tag, sortedBy: \.title, order: .ascending))
    }
}
