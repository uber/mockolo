import Foundation
import XCTest

class OutputChangeTests: MockoloTestCase {
    func testFileWriteBehavior() throws {
        verify(srcContent: simpleFuncs._source,
               dstContent: simpleFuncs.expected._source)

        let expectedAttributes = try FileManager.default.attributesOfItem(atPath: defaultDstFilePath)
        let expectedCreationDate = expectedAttributes[.creationDate] as? Date
        let expectedModificationDate = expectedAttributes[.modificationDate] as? Date

        verify(srcContent: simpleFuncs._source,
               dstContent: simpleFuncs.expected._source)

        let attributes = try FileManager.default.attributesOfItem(atPath: defaultDstFilePath)
        let creationDate = attributes[.creationDate] as? Date
        let modificationDate = attributes[.modificationDate] as? Date

        XCTAssertEqual(creationDate, expectedCreationDate)
        XCTAssertEqual(modificationDate, expectedModificationDate)
    }
}
