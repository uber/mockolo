// swift-tools-version:5.1
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.5.0")),
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.26.0"),
]

#if swift(>=5.2)
dependencies.append(.package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50200.0")))
#elseif swift(>=5.1)
dependencies.append(.package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")))
#endif

let package = Package(
    name: "Mockolo",
    platforms: [
        .macOS(.v10_14),
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
                "SPMUtility",
                "MockoloFramework",
                ]),
        .target(
            name: "MockoloFramework",
            dependencies: [
                "SourceKittenFramework",
                "SwiftSyntax",
            ]
        ),
        .testTarget(
            name: "MockoloTests",
            dependencies: [
                "MockoloFramework",
            ],
            path: "Tests"
        )
    ]
)

