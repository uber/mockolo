import Foundation
import XCTest

class ThrowingErrorsTests: MockoloTestCase {
    func testNonexistentDestinationDirectoryError() {
        let nonExistentDstDirPath = "/nonexistent/directory"
        
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: nonExistentDstDirPath),
            "\(nonExistentDstDirPath) is expected not to exist, but it exists"
        )
        
        verifyThrows(srcContent: simpleFuncs,
                     dstContent: simpleFuncsMock,
                     dstFilePath: nonExistentDstDirPath + "/Dst.swift")
    }
}
