// swift-tools-version:5.4
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .exact("0.2.3")),
    .package(url: "https://github.com/apple/swift-argument-parser", "1.0.1"..."1.0.3"),
]
var mockoloFrameworkTargetDependencies: [Target.Dependency] = [
    .product(name: "SwiftSyntax", package: "SwiftSyntax"),
]

#if swift(>=5.6)
dependencies.append(.package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch("release/5.6")))
mockoloFrameworkTargetDependencies.append(.product(name: "SwiftSyntaxParser", package: "SwiftSyntax"))
#elseif swift(>=5.5)
dependencies.append(.package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50500.0")))
#else
dependencies.append(.package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0")))
#endif

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
            dependencies: mockoloFrameworkTargetDependencies,
            exclude: [
                "README.md",
                "LICENSE.txt",
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

