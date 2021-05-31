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
                    Link(adventure.name, url: adventure.path)
                    MissingCell(adventure.length?.localizedStringValue)
                    MissingCell(tierString(for: adventure))
                    MissingCell(adventure.apl.map { $0.joined(seperator: ", ") })
                }
            }
        }
    }

    func tierString(for adventure: Adventure) -> String? {
        guard let tier = adventure.tier else { return nil }

        if (tier.count == 4) {
            return NSLocalizedString("All", bundle: Bundle.module, comment: "All Tiers")
        } else {
            return tier.map(\.rawValue).joined(seperator: ", ")
        }
    }
}


struct MissingCell: Component {
    var value: String?

    init(_ value: String?) {
        self.value = value
    }

    @ComponentBuilder
    var body: Component {
        if let value = value {
            TableCell(value)
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
