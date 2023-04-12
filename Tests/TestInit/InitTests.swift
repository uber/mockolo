import Foundation
import XCTest

class InitTests: MockoloTestCase {
   func testSimpleInitParams() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock)
    }

    func testNonSimpleInitParams() {
        verify(srcContent: nonSimpleInitVars,
               dstContent: nonSimpleInitVarsMock)
    }

    func testBlankInitMethod() {
        verify(srcContent: protocolWithBlankInit,
               dstContent: protocolWithBlankInitMock)
    }

    func testInitMethod() {
        verify(srcContent: protocolWithInit,
               mockContent: protocolWithInitParentMock,
               dstContent: protocolWithInitResultMock)
    }

    func testInitKeywordParams() {
        verify(srcContent: keywordParams,
               dstContent: keywordParamsMock)
    }

    func testInitiWithSameParamName() {
        verify(
            srcContent: multipleInitsWithSameParamName,
            dstContent: multipleInitsWithSameParamNameMock
        )
    }

    func testInitiWithSameParamNameWithTypeDifference() throws {
        throw XCTSkip("This feature will be implemented in future work.")
        verify(
            srcContent: multipleTypeAwarenessInitsWithSameParamName,
            dstContent: multipleTypeAwarenessInitsWithSameParamNameMock
        )
    }
}
