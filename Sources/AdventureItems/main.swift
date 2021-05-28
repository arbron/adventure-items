import Foundation
import Files
import Publish
import Plot
import Yams

// This type acts as the configuration for your website.
struct AdventureItemsSite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case adventures
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var adventure: Adventure
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://arbron.github.io/adventure-items/")!
    var name = NSLocalizedString("title", bundle: Bundle.module, comment: "")
    var description = NSLocalizedString("site-description", bundle: Bundle.module, comment: "")
    var language: Language { .english }
    var imagePath: Path? { nil }

    static let indentationMode: Indentation.Kind = .spaces(2)
}

// Load data
var adventures = try Adventure.load()


// This will generate your website using the built-in Foundation theme:
try AdventureItemsSite().publish(using: [
    .addMarkdownFiles(),
    .copyResources(),
    .addAdventures(adventures),
    .addSpreadsheet(adventures),
    .generateHTML(withTheme: .league, indentation: AdventureItemsSite.indentationMode),
    .generateRSSFeed(including: [.adventures]),
    .generateSiteMap()
])
