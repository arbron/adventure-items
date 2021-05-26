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
        ),
        .library(
            name: "AdventureUtils",
            targets: ["AdventureUtils"]
        )
    ],
    dependencies: [
        .package(name: "Ink", url: "https://github.com/johnsundell/ink.git", from: "0.5.0"),
        .package(name: "Plot", url: "https://github.com/johnsundell/plot.git", from: "0.9.0"),
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.8.0"),
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.6")
    ],
    targets: [
        .target(
            name: "AdventureItems",
            dependencies: ["AdventureUtils", "Ink", "Plot", "Publish", "Yams"]
        ),
        .target(name: "AdventureUtils"),
        .testTarget(
            name: "AdventureUtilsTests",
            dependencies: ["AdventureUtils"]
        )
    ]
)
