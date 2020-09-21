// swift-tools-version:5.3
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.4")),
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .exact("0.1.5")),
]

dependencies.append(.package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch("swift-5.3-RELEASE")))

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

