//
//  SinglePage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

import Plot
import Publish


extension LeagueHTMLFactory {
    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                WrappedPage(for: context) {
                    SinglePageBody(page.body)
                }.convertToNode()
            )
        )
    }
}


struct SinglePageBody: Component {
    var content: Content.Body

    init(_ content: Content.Body) {
        self.content = content
    }

    @ComponentBuilder
    var body: Component {
        content.node
    }
}

