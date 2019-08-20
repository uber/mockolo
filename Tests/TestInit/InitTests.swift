import Foundation

class InitTests: MockoloTestCase {
   func testInitParams() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock)
    }

    func testInitMethod() {
        verify(srcContent: protocolWithInit,
               mockContent: simpleInitParentMock,
               dstContent: protocolWithInitResultMock)
    }
}
