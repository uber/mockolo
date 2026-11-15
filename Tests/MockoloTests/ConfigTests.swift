#if canImport(Testing)
import Foundation
import Testing

@Suite struct ConfigTests {
    @Test func resolvesPathsRelativeToConfigFile() throws {
        let result = try runMockolo(
            config: #"{ sources: ["Sources", "B.swift"], destination: "Mocks.swift", }"#,
            files: ["Sources/A.swift": mockable("protocol A {}"), "B.swift": mockable("protocol B {}")]
        )

        #expect(result.status == 0)
        #expect(result.mocks.contains("class AMock"))
        #expect(result.mocks.contains("class BMock"))
    }

    @Test func commandLineOverridesSourcesAndDestination() throws {
        let result = try runMockolo(
            config: #"{ sources: ["Sources"], destination: "Mocks.swift" }"#,
            files: ["Sources/A.swift": mockable("protocol A {}"), "Other/C.swift": mockable("protocol C {}")],
            arguments: { dir in
                ["--sourcedirs", dir.appendingPathComponent("Other").path,
                 "--destination", dir.appendingPathComponent("OtherMocks.swift").path]
            },
            destination: "OtherMocks.swift"
        )

        #expect(result.status == 0)
        #expect(result.mocks.contains("class CMock"))
        #expect(!result.mocks.contains("class AMock"))
    }

    @Test(arguments: [
        (#"{ sourcez: [] }"#, "sourcez: unknown key"),
        (#"{ sources: "x" }"#, "sources: expected"),
        (#"{ sources: ["Missing"], destination: "Mocks.swift" }"#, "sources[0]: no such file or directory"),
    ])
    func invalidConfigFails(config: String, message: String) throws {
        let result = try runMockolo(config: config)

        #expect(result.status == 64)
        #expect(result.stderr.contains("\(result.configPath): \(message)"))
    }
}

private struct Run {
    let status: Int32
    let stderr: String
    let configPath: String
    let mocks: String
}

private final class BundleMarker {}

/// Writes `config` and `files` into a new temporary directory, runs mockolo with `--config` followed by
/// `arguments(directory)`, and reads `destination` from that directory.
private func runMockolo(
    config: String,
    files: [String: String] = [:],
    arguments: (URL) -> [String] = { _ in [] },
    destination: String = "Mocks.swift"
) throws -> Run {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    for (path, content) in files.merging(["config.json5": config], uniquingKeysWith: { $1 }) {
        let url = dir.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    let configPath = dir.appendingPathComponent("config.json5").path

    #if os(macOS)
    let productsDirectory = Bundle(for: BundleMarker.self).bundleURL.deletingLastPathComponent()
    #else
    let productsDirectory = Bundle.main.bundleURL
    #endif
    let process = Process()
    process.executableURL = productsDirectory.appendingPathComponent("mockolo")
    process.arguments = ["--config", configPath] + arguments(dir)
    process.standardOutput = FileHandle.nullDevice
    let stderr = Pipe()
    process.standardError = stderr
    try process.run()
    let output = stderr.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()

    let mocks = (try? String(contentsOf: dir.appendingPathComponent(destination), encoding: .utf8)) ?? ""
    return Run(status: process.terminationStatus, stderr: String(decoding: output, as: UTF8.self), configPath: configPath, mocks: mocks)
}

private func mockable(_ declaration: String, annotation: String = "@mockable") -> String {
    "/// \(annotation)\n\(declaration)"
}
#endif
