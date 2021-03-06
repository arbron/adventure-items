import Foundation
import Files
import Publish
import Plot

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
    var name = "Adventure Items"
    var description = "Find a D&D adventure to give your character the perfect piece of swag."
    var language: Language { .english }
    var imagePath: Path? { nil }

    static let indentationMode: Indentation.Kind = .spaces(2)
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .formatted(.iso8601date)

let dataFolder = try Folder.packageFolder(path: "Sources/Data/")
let files = dataFolder.files.compactMap { $0.extension == "json" ? $0 : nil }

let adventures: [Adventure] = try decoder.decode([Adventure].self, files: files)

// This will generate your website using the built-in Foundation theme:
try AdventureItemsSite().publish(using: [
    .addMarkdownFiles(),
    .copyResources(),
    .addAdventures(adventures, removeIncomplete: true),
    .generateHTML(withTheme: .league, indentation: AdventureItemsSite.indentationMode),
    .generateRSSFeed(including: [.adventures]),
    .generateSiteMap()
])
