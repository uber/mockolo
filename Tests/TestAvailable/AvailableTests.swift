class AvailableTests: MockoloTestCase {
    func testMemberAvailableFunc() {
        verify(srcContent: memberAvailableFunc._source,
               dstContent: memberAvailableFunc.expected._source)
    }

    func testProtocolAndMemberAvailable() {
        verify(srcContent: protocolAndMemberAvailable._source,
               dstContent: protocolAndMemberAvailable.expected._source)
    }

    func testMultipleAvailableOnMethod() {
        verify(srcContent: multipleAvailableOnMethod._source,
               dstContent: multipleAvailableOnMethod.expected._source)
    }

    func testMemberAvailableVar() {
        verify(srcContent: memberAvailableVar._source,
               dstContent: memberAvailableVar.expected._source)
    }

    #if compiler(>=6.0)
    func testMemberAvailableSendable() {
        verify(srcContent: memberAvailableSendable._source,
               dstContent: memberAvailableSendable.expected._source)
    }

    func testReportedIssue() {
        verify(srcContent: reportedIssue._source,
               dstContent: reportedIssue.expected._source,
               enableFuncArgsHistory: true)
    }
    #endif

    func testMemberPlatformAvailable() {
        verify(srcContent: memberPlatformAvailable._source,
               dstContent: memberPlatformAvailable.expected._source)
    }
}
