import Foundation
import MockoloFramework
import XCTest

final class FileScannerTests: XCTestCase {
    func testDirectoryWithSwiftSuffixIsNotReturnedAsSourceFile() {
        let testFile = URL(fileURLWithPath: #filePath)
        let swiftSuffixDirectory = testFile.deletingLastPathComponent()
        let testsDirectory = swiftSuffixDirectory.deletingLastPathComponent()
        var scannedPaths = [String]()

        scan(dirs: [testsDirectory.path], numThreads: 1) { path, _ in
            scannedPaths.append(path)
        }

        XCTAssertTrue(scannedPaths.contains(testFile.path))
        XCTAssertFalse(scannedPaths.contains(swiftSuffixDirectory.path))
    }

    func testSymbolicLinkToDirectoryIsNotReturnedAsSourceFile() throws {
        let fixtureDirectory = FileManager.default.temporaryDirectory
            .resolvingSymlinksInPath()
            .appendingPathComponent(
                "MockoloFileScannerTests-\(UUID().uuidString)",
                isDirectory: true
            )
        let targetDirectory = fixtureDirectory.appendingPathComponent(
            "DirectoryTarget",
            isDirectory: true
        )
        let targetFile = targetDirectory.appendingPathComponent("File.swift")
        let directoryLink = fixtureDirectory.appendingPathComponent("DirectoryLink.swift")
        let fileLink = fixtureDirectory.appendingPathComponent("FileLink.swift")

        try FileManager.default.createDirectory(
            at: targetDirectory,
            withIntermediateDirectories: true
        )
        XCTAssertTrue(FileManager.default.createFile(atPath: targetFile.path, contents: nil))
        try FileManager.default.createSymbolicLink(
            atPath: directoryLink.path,
            withDestinationPath: targetDirectory.path
        )
        try FileManager.default.createSymbolicLink(
            atPath: fileLink.path,
            withDestinationPath: targetFile.path
        )

        var scannedPaths = [String]()
        scan(dirs: [fixtureDirectory.path], numThreads: 1) { path, _ in
            scannedPaths.append(path)
        }
        let scannedFileNames = Set(scannedPaths.map {
            URL(fileURLWithPath: $0).lastPathComponent
        })

        XCTAssertEqual(scannedFileNames, [targetFile.lastPathComponent, fileLink.lastPathComponent])
        XCTAssertFalse(scannedFileNames.contains(directoryLink.lastPathComponent))
    }
}
