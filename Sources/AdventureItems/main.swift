import Foundation
import Files
import Publish
import Plot

// This type acts as the configuration for your website.
struct AdventureItems: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://arbron.github.io/adventure-items/")!
    var name = "Adventure Items"
    var description = "Find a D&D adventure to give your character the perfect piece of swag."
    var language: Language { .english }
    var imagePath: Path? { nil }
}

let adventuresFile = try File.packageFile(path: "Resources/adventures.json")
let decoder = JSONDecoder()
let adventures = try decoder.decode([Adventure].self, from: Data(contentsOf: adventuresFile.url))

let adventureList: [Publish.Item<AdventureItems>] = adventures.map { adventure in
    Publish.Item(
        path: Path(adventure.code.lowercased()),
        sectionID: AdventureItems.SectionID.posts,
        metadata: AdventureItems.ItemMetadata(),
        tags: [],
        content: Content(
            title: "\(adventure.code) - \(adventure.name)",
            body: "\(adventure.code)"
        )
    )
}

// This will generate your website using the built-in Foundation theme:
try AdventureItems().publish(
    withTheme: .foundation,
    additionalSteps: [
        .addItems(in: adventureList),
        .sortItems(by: \.content.title)
    ]
)
