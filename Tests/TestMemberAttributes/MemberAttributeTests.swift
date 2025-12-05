import Foundation
import XCTest

class MemberAttributeTests: MockoloTestCase {
    func testMemberAttributes() {
        verify(srcContent: memberAttributes._source,
               dstContent: memberAttributes.expected._source)
    }
}


