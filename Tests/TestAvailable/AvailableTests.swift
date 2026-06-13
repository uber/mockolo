class AvailableTests: MockoloTestCase {
    func testDeprecatedMembers() {
        verify(srcContent: deprecatedMembers._source,
               dstContent: deprecatedMembers.expected._source)
    }

    func testProtocolAndMemberAvailable() {
        verify(srcContent: protocolAndMemberAvailable._source,
               dstContent: protocolAndMemberAvailable.expected._source)
    }

    func testMultipleAvailableOnMethod() {
        verify(srcContent: multipleAvailableOnMethod._source,
               dstContent: multipleAvailableOnMethod.expected._source)
    }

    func testMemberPlatformAvailable() {
        verify(srcContent: memberPlatformAvailable._source,
               dstContent: memberPlatformAvailable.expected._source)
    }
}
