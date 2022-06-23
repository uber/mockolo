import Foundation
import XCTest

class ThrowingErrorsTests: MockoloTestCase {
    func testNonexistentDestinationDirectoryError() {
        let nonExistentOutputDirPath = "/nonexistent/directory"
        
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: nonExistentOutputDirPath),
            "\(nonExistentOutputDirPath) is expected not to exist, but it exists"
        )
        
        verifyThrows(srcContent: simpleFuncs,
                     dstContent: simpleFuncsMock,
                     outputFilePath: nonExistentOutputDirPath + "/Dst.swift")
    }
}
