import Foundation

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

    func testInitWithSameParamName() {
        verify(
            srcContent: multipleInitsWithSameParamName,
            dstContent: multipleInitsWithSameParamNameMock
        )
    }

    func testInitWithSameParamNameButDifferentType() {
        verify(
            srcContent: initWithSameParamNameButDifferentType,
            dstContent: initWithSameParamNameButDifferentTypeMock
        )
    }

	func testThrowableInit() {
		verify(
			srcContent: throwableInit,
			dstContent: throwableInitMock
		)
	}
}
