// swift-tools-version:5.4
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .exact("0.2.3")),
    .package(url: "https://github.com/apple/swift-argument-parser", .exact("1.0.1")),
]

let swiftSyntax: Package.Dependency
#if swift(>=5.5)
swiftSyntax = .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50500.0"))
#else
swiftSyntax = .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0"))
#endif
dependencies.append(swiftSyntax)

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
        .executableTarget(
            name: "Mockolo",
            dependencies: [
                "MockoloFramework",
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
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

