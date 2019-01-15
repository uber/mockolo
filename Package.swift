// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftMockGen",
    products: [
        .executable(name: "swift-mockgen", targets: ["SwiftMockGen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.20.0"),
    ],
    targets: [
        .target(
            name: "SwiftMockGen",
            dependencies: [
                "Utility",
                "SourceKittenFramework",
            ],
            path: "."
            ),
    ],
    swiftLanguageVersions: [4]
)

