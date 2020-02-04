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


    func testInitMethod() {
        verify(srcContent: protocolWithInit,
               mockContent: protocolWithInitParentMock,
               dstContent: protocolWithInitResultMock)
    }
}
