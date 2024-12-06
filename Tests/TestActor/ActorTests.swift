final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: actorProtocol.source,
               dstContent: actorProtocol.expected)
    }

    func testParentProtocolInheritsActor() {
        verify(srcContent: parentProtocolInheritsActor.source,
               dstContent: parentProtocolInheritsActor.expected)
    }

    func testGlobalActorProtocol() {
        verify(srcContent: globalActorProtocol.source,
               dstContent: globalActorProtocol.expected)
    }
}
