//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-28.
//

import Foundation
import Plot
import Publish


//struct SeriesPageBody: Component {
//    let series: Series
//
//    @ComponentBuilder
//    var body: Component {
//        H1(series.name)
//        Paragraph(series.description)
//        List(series.adventures) { adventure in
//            Text(adventure.code)
//        }
//    }
//}
//
//
//// MARK: - Building Steps
//
//extension PublishingStep where Site == AdventureItemsSite {
//    static func addSeries(_ series: [Series]) -> Self {
//        step(named: "Add Series") { context in
//            for aSeries in series {
//                context.addItem(.item(for: aSeries))
//            }
//        }
//    }
//}
//
//extension Publish.Item where Site == AdventureItemsSite {
//    static func item(for series: Series) -> Self {
//        return Self(
//            path: Path(series.slug),
//            sectionID: AdventureItemsSite.SectionID.series,
//            metadata: .init(series: series),
//            tags: [],
//            content: Content(
//                title: series.name,
//                description: series.description,
//                body: .init(indentation: .spaces(2)) {
//                    SeriesPageBody(series: series)
//                },
//                date: Date.distantPast
//            )
//        )
//    }
//}
