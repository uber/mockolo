import Foundation

final class MockActorTests: MockoloTestCase {

    func testActorProtocol() {
        verify(srcContent: actorProtocol,
               dstContent: actorProtocolMock)
    }
}
