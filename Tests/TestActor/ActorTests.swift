final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: actorProtocol._source,
               dstContent: actorProtocol.expected._source)
    }

    func testParentProtocolInheritsActor() {
        verify(srcContent: parentProtocolInheritsActor._source,
               dstContent: parentProtocolInheritsActor.expected._source)
    }

    func testGlobalActorProtocol() {
        verify(srcContent: globalActorProtocol._source,
               dstContent: globalActorProtocol.expected._source)
    }
}
