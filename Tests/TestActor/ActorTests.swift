final class ActorTests: MockoloTestCase {
    func testActorProtocol() {
        verify(srcContent: actorProtocol,
               dstContent: actorProtocolMock)
    }

    func testParentProtocolInheritsActor() {
        verify(srcContent: parentProtocolInheritsActor,
               dstContent: parentProtocolInheritsActorMock)
    }

    func testGlobalActorProtocol() {
        verify(srcContent: globalActorProtocol,
               dstContent: globalActorProtocolMock)
    }

    func testAttributeAboveAnnotationComment() {
        verify(srcContent: attributeAboveAnnotationComment,
               dstContent: attributeAboveAnnotationCommentMock)
    }
}
