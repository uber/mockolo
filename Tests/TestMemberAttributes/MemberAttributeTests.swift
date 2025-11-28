import Foundation
import XCTest

class MemberAttributeTests: MockoloTestCase {
    func testMethodAndVariableAttributes() {
        verify(srcContent: methodAndVariableAttributes,
               dstContent: methodAndVariableAttributesMock)
    }
}


