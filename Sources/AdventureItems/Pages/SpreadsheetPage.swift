//
//  SpreadsheetPage.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-27.
//

import Foundation
import Plot
import Publish
import Ink


struct Spreadsheet: Component {
    let adventures: [Adventure]

    var body: Component {
        Table(header: TableRow {
            Text("Code")
            Text("Title")
            Text("Length")
            Text("Tier")
            Text("APL")
        }) {
            for adventure in adventures {
                TableRow {
                    Text(adventure.code)
                    Link(adventure.name, url: "/adventures/\(adventure.path)/")
                    Text("\(adventure.length?.localizedStringValue ?? "—")")
                    if let tier = adventure.tier {
                        if (tier.count == 4) {
                            Text(NSLocalizedString("All", bundle: Bundle.module, comment: "All Tiers"))
                        } else {
                            Text(tier.map(\.rawValue).joined(seperator: ", "))
                        }
                    } else {
                        TableCell("—").class("missing")
                    }
                    NumberList(value: adventure.apl)
                }
            }
        }
    }
}


struct NumberList<T>: Component {
    let value: [T]?
    var formatter: (T) -> String = { "\($0)" }

    @ComponentBuilder
    var body: Component {
        if let value = value {
            Text(value.map(formatter).joined(seperator: ", "))
        } else {
            TableCell("—").class("missing")
        }
    }
}


// MARK: - Building Steps

extension PublishingStep where Site == AdventureItemsSite {
    static func addSpreadsheet(_ adventures: [Adventure]) -> Self {
        step(named: "Add Spreadsheet") { context in
            context.addPage(Page(path: "spreadsheet", content: .spreadsheet(for: adventures)))
        }
    }
}

fileprivate extension Content {
    static func spreadsheet(for adventures: [Adventure]) -> Self {
        return .init(
            title: NSLocalizedString("spreadsheet-title", bundle: Bundle.module, comment: ""),
            description: NSLocalizedString("spreadsheet-description", bundle: Bundle.module, comment: ""),
            body: .spreadsheet(for: adventures),
            date: .distantPast,
            lastModified: Date()
        )
    }
}

fileprivate extension Content.Body {
    static func spreadsheet(for adventures: [Adventure]) -> Self {
        .init(indentation: .spaces(2)) {
            Spreadsheet(adventures: adventures)
        }
    }
}
