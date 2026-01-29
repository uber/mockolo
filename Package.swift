// swift-tools-version:5.10
import CompilerPluginSupport
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "Mockolo",
            dependencies: [
                "MockoloFramework",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "MockoloFramework",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .macro(
            name: "MockoloTestSupportMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "MockoloTests",
            dependencies: [
                "MockoloFramework",
                "MockoloTestSupportMacros",
            ],
            path: "Tests"
        ),
    ]
)
