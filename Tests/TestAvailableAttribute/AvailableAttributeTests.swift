import Foundation
import XCTest

class AvailableAttributeTests: MockoloTestCase {
    func testAvailableDeprecated() {
        verify(srcContent: availableDeprecated,
               dstContent: availableDeprecatedMock)
    }
}

