// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Mockolo",
    products: [
        .executable(name: "mockolo", targets: ["Mockolo"]),
        .library(name: "MockoloFramework", targets: ["MockoloFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
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

