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

    func testDuplicatedAttributes() {
        verify(srcContent: duplicatedAttributes._source,
               dstContent: duplicatedAttributes.expected._source,
               enableFuncArgsHistory: true)
    }
    #endif

    func testMemberPlatformAvailable() {
        verify(srcContent: memberPlatformAvailable._source,
               dstContent: memberPlatformAvailable.expected._source)
    }

    func testMixedPlatformAndBehavioralAvailable() {
        verify(srcContent: mixedPlatformAndBehavioralAvailable._source,
               dstContent: mixedPlatformAndBehavioralAvailable.expected._source)
    }

    func testPlatformScopedDeprecation() {
        verify(srcContent: platformScopedDeprecation._source,
               dstContent: platformScopedDeprecation.expected._source)
    }

    func testGatingAvailabilityStillHoisted() {
        verify(srcContent: gatingAvailabilityStillHoisted._source,
               dstContent: gatingAvailabilityStillHoisted.expected._source)
    }

    func testUnavailableStillHoisted() {
        verify(srcContent: unavailableStillHoisted._source,
               dstContent: unavailableStillHoisted.expected._source)
    }

    func testMemberAvailableCombineVar() {
        verify(srcContent: memberAvailableCombineVar._source,
               dstContent: memberAvailableCombineVar.expected._source)
    }

    func testMemberAvailableRxVar() {
        verify(srcContent: memberAvailableRxVar._source,
               dstContent: memberAvailableRxVar.expected._source)
    }

    func testMemberAvailableSubscript() {
        verify(srcContent: memberAvailableSubscript._source,
               dstContent: memberAvailableSubscript.expected._source)
    }

    func testMemberAvailableInit() {
        verify(srcContent: memberAvailableInit._source,
               dstContent: memberAvailableInit.expected._source)
    }
}
