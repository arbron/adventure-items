// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AdventureItems",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "AdventureItems",
            targets: ["AdventureItems"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "AdventureItems",
            dependencies: ["Publish"]
        )
    ]
)
