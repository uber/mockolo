// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Mockolo",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "mockolo", targets: ["Mockolo"]),
        .library(name: "MockoloFramework", targets: ["MockoloFramework"]),
    ],
    dependencies: [
		.package(
			url: "https://github.com/swiftlang/swift-syntax",
			from: "600.0.0-prerelease-2024-06-12"
		),
		.package(
			url: "https://github.com/apple/swift-argument-parser",
			from: "1.2.2"
		),
    ],
    targets: [
        .executableTarget(
            name: "Mockolo",
            dependencies: [
                "MockoloFramework",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .target(
            name: "MockoloFramework",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
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
