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

    struct ItemMetadata: WebsiteItemMetadata { }

    // Update these properties to configure your website:
    var url = URL(string: "https://arbron.github.io/adventure-items/")!
    var name = "Adventure Items"
    var description = "Find a D&D adventure to give your character the perfect piece of swag."
    var language: Language { .english }
    var imagePath: Path? { nil }
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .formatted(.iso8601date)

let files: [File] = [
    try File.packageFile(path: "Sources/Data/conventionCreatedContent.json"),
    try File.packageFile(path: "Sources/Data/hardcovers.json"),
    try File.packageFile(path: "Sources/Data/season0.json"),
    try File.packageFile(path: "Sources/Data/season1.json"),
    try File.packageFile(path: "Sources/Data/season2.json"),
    try File.packageFile(path: "Sources/Data/season3.json"),
    try File.packageFile(path: "Sources/Data/season4.json"),
    try File.packageFile(path: "Sources/Data/season5.json"),
    try File.packageFile(path: "Sources/Data/season6.json"),
    try File.packageFile(path: "Sources/Data/season7.json"),
    try File.packageFile(path: "Sources/Data/season8.json"),
    try File.packageFile(path: "Sources/Data/season9.json")
]

let adventures: [Adventure] = try decoder.decode([Adventure].self, files: files)
let adventureList: [Publish.Item<AdventureItemsSite>] = adventures.map { .item(for: $0) }

let publishSteps: [PublishingStep<AdventureItemsSite>] = [
    .addMarkdownFiles(),
    .copyResources(),
    .addItems(in: adventureList),
    .sortItems(by: \.content.title),
    .generateHTML(withTheme: .league),
    .generateRSSFeed(including: [.adventures]),
    .generateSiteMap(),
    .installPlugin(try .prependAllPaths("adventure-items/"))
]

// This will generate your website using the built-in Foundation theme:
try AdventureItemsSite().publish(using: publishSteps)
