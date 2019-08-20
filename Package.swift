// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Mockolo",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "mockolo", targets: ["Mockolo"]),
        .library(name: "MockoloFramework", targets: ["MockoloFramework"]),
        ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.4.0")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.23.0"),
        ],
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
                "SourceKittenFramework"
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

