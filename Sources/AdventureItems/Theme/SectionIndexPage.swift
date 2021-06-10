//
//  SectionIndexPage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

import Plot
import Publish


extension LeagueHTMLFactory {
    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                WrappedPage(for: context) {
                    SectionIndexPageBody(section: section)
                }.convertToNode()
            )
        )
    }
}


struct SectionIndexPageBody<S: Website>: Component {
    var section: Section<S>

    @ComponentBuilder
    var body: Component {
        H1(section.title)
        AdventureList(items: section.items)
    }
}

