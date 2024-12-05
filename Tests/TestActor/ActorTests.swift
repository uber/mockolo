final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: ActorProtocol_Fixture.code,
               dstContent: ActorProtocolMock_Fixture.code)
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
