import Foundation

#if compiler(>=5.5.2) && canImport(_Concurrency)
final class MockActorTests: MockoloTestCase {

    func testActorProtocol() {
        verify(srcContent: actorProtocol,
               dstContent: actorProtocolMock)
    }
}
#endif
