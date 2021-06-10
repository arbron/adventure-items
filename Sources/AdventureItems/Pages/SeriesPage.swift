//
//  SeriesPage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-28.
//

import Foundation
import Plot
import Publish


struct SeriesPage: Component {
    let series: Series

    @ComponentBuilder
    var body: Component {
        H1(series.name)
        subHeading

        Paragraph(series.description)
        AdventuresSection(series.adventures)
    }

    var subHeading: Component {
        var key = "<Source>"
        var args: [CVarArg] = ["Series".localized()]

        if let tiersString = series.tiers?.localizedString() {
            key += " for <Tier>"
            args.append(tiersString)
        }

        return H3 {
            Text(key.localizedAndFormatted(args))
        }
    }
}

struct AdventuresSection: Component {
    let adventures: [Series.Entry]

    init(_ adventures: [Series.Entry]) {
        self.adventures = adventures
    }

    @ComponentBuilder
    var body: Component {
        for adventure in adventures {
            H3 {
                Link(adventure.name, url: adventure.path)
                Text(adventure.code).italic().class("adventure-code")
            }
            Paragraph(adventure.description)
        }
    }
}


// MARK: - Building Steps

extension PublishingStep where Site == AdventureItemsSite {
    static func addSeries(_ series: [Series]) -> Self {
        step(named: "Add Series") { context in
            for aSeries in series {
                context.addItem(.item(for: aSeries))
            }
        }
    }
}

extension Publish.Item where Site == AdventureItemsSite {
    static func item(for series: Series) -> Self {
        var aSeries = series

        var tags: Set<Tag> = []
        aSeries.tiers = .init()

        for adventure in series.adventures {
            _ = adventure.tiers.map {
                aSeries.tiers?.insert($0)
                tags.insert(Tag("tags.adventureTier".localizedAndFormatted($0.rawValue)))
            }
        }

        return Self(
            path: Path(series.slug),
            sectionID: AdventureItemsSite.SectionID.series,
            metadata: .init(series: series),
            tags: Array(tags).sorted(),
            content: Content(
                title: series.name,
                description: series.description,
                body: .init(indentation: .spaces(2)) {
                    SeriesPage(series: aSeries)
                },
                date: Date.distantPast
            )
        )
    }
}
