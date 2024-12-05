final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: ActorProtocol_rawSyntax,
               dstContent: ActorProtocolMock_rawSyntax)
    }

    func testParentProtocolInheritsActor() {
        verify(srcContent: parentProtocolInheritsActor,
               dstContent: parentProtocolInheritsActorMock)
    }

    func testGlobalActorProtocol() {
        verify(srcContent: globalActorProtocol,
               dstContent: globalActorProtocolMock)
    }
}
