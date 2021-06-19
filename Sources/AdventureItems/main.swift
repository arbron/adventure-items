import AdventureUtils
import Foundation
import Files
import Publish
import Plot
import Yams

// This type acts as the configuration for your website.
struct AdventureItemsSite: Website {
    enum SectionID: String, WebsiteSectionID {
        case adventures
        case series
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var adventure: Adventure?
        var series: Series?
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://arbron.github.io/adventure-items/")!
    var name = "site.title".localized()
    var description = "site.description".localized()
    var language: Language { .english }
    var imagePath: Path? { nil }

    static let indentationMode: Indentation.Kind = .spaces(2)
}


// Load data
let database = try Database()


// This will generate your website using the built-in Foundation theme:
try AdventureItemsSite().publish(using: [
    .addMarkdownFiles(),
    .copyResources(),
    .addAdventures(database.adventures),
    .addSeries(database.series),
    .addSpreadsheet(database.adventures),
    .generateHTML(withTheme: .league, indentation: AdventureItemsSite.indentationMode),
    .generateRSSFeed(including: [.adventures]),
    .generateSiteMap()
])
