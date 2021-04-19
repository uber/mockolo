import Foundation

class ProtocolAssociatedTypeTests: MockoloTestCase {

    func testPATDefaultType() {
        verify(srcContent: patDefaultType,
               dstContent: patDefaultTypeMock)
    }

    func testPATPartialOverrideTypealiases() {
        verify(srcContent: patPartialOverride,
               dstContent: patPartialOverrideMock)
    }

    func testPATOverrideTypealiases() {
        verify(srcContent: patOverride,
               dstContent: patOverrideMock)
    }
    
    func testPATWithParentMock() {
        verify(srcContent: simplePat,
               mockContent: parentPatMock,
               dstContent: patWithParentMock)
    }

    func testPATNameCollisions() {
        verify(srcContent: patNameCollision,
               dstContent: patNameCollisionMock)
    }
    
    func testTypealias() {
        verify(srcContent: protocolWithTypealias,
               dstContent: protocolWithTypealiasMock)
    }
}
