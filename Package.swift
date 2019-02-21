// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftMockGen",
    products: [
        .executable(name: "swiftmockgen", targets: ["SwiftMockGen"]),
        .library(name: "SwiftMockGenCore", targets: ["SwiftMockGenCore"]),
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
                "SwiftMockGenCore",
            ]),
        .target(
                    name: "SwiftMockGenCore",
                    dependencies: [
                        "SourceKittenFramework"
                    ]
        )

    ],
    swiftLanguageVersions: [4]
)

