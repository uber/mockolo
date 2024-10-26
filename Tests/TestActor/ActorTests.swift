final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: actorProtocol,
               dstContent: actorProtocolMock)
    }

    func testParentProtocolInheritsActor() {
        verify(srcContent: parentProtocolInheritsActor,
               dstContent: parentProtocolInheritsActorMock)
    }
}
