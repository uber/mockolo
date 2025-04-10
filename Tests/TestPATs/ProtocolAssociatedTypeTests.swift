class ProtocolAssociatedTypeTests: MockoloTestCase {
    func testPATWithParentMock() {
        verify(srcContent: simplePat._source,
               mockContent: simplePat.parent._source,
               dstContent: simplePat.expected._source)
    }

    func testPATOverrideTypealiases() {
        verify(srcContent: patOverride._source,
               dstContent: patOverride.expected._source)
    }

    func testPATPartialOverrideTypealiases() {
        verify(srcContent: patPartialOverride._source,
               dstContent: patPartialOverride.expected._source)
    }

    func testTypealias() {
        verify(srcContent: protocolWithTypealias._source,
               dstContent: protocolWithTypealias.expected._source)
    }

    func testPATDefaultType() {
        verify(srcContent: patDefaultType._source,
               dstContent: patDefaultType.expected._source)
    }

    func testPATWithConditions() {
        verify(srcContent: patWithConditions._source,
               dstContent: patWithConditions.expected._source)
    }
#if compiler(>=6.0)
    func testPATWithParentCondition() {
        verify(srcContent: patWithParentCondition._source,
               dstContent: patWithParentCondition.expected._source)
    }

    func testPATNameCollisions() {
        verify(srcContent: patNameCollision._source,
               dstContent: patNameCollision.expected._source)
    }
#endif
}
