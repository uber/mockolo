// swift-tools-version:5.2
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.4")),
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("master")),
    .package(url: "https://github.com/jpsim/SourceKitten", from: "0.29.0"),
    .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50200.0"))
]

let package = Package(
    name: "Mockolo",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "mockolo", targets: ["Mockolo"]),
        .library(name: "MockoloFramework", targets: ["MockoloFramework"]),
        ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Mockolo",
            dependencies: [
                "MockoloFramework",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                ]),
        .target(
            name: "MockoloFramework",
            dependencies: [
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
            ]
        ),
        .testTarget(
            name: "MockoloTests",
            dependencies: [
                "MockoloFramework",
            ],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)

