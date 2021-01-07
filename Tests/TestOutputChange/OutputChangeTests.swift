import Foundation
import XCTest

class OutputChangeTests: MockoloTestCase {
    func testFileWriteBehavior() throws {
        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)

        let expectedAttributes = try FileManager.default.attributesOfItem(atPath: dstFilePath)
        let expectedCreationDate = (expectedAttributes[.creationDate] as! Date).timeIntervalSinceReferenceDate
        let expectedModificationDate = (expectedAttributes[.modificationDate] as! Date).timeIntervalSinceReferenceDate

        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)

        let attributes = try FileManager.default.attributesOfItem(atPath: dstFilePath)
        let creationDate = (attributes[.creationDate] as! Date).timeIntervalSinceReferenceDate
        let modificationDate = (attributes[.modificationDate] as! Date).timeIntervalSinceReferenceDate

        XCTAssertEqual(creationDate, expectedCreationDate)
        XCTAssertEqual(modificationDate, expectedModificationDate)
    }
}
