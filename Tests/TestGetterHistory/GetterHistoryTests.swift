import XCTest

class GetterHistoryTests: MockoloTestCase {

    // MARK: - Annotation-driven (string-diff) cases

    func testGetterHistorySpecific() {
        verify(srcContent: getterHistorySpecific._source,
               dstContent: getterHistorySpecific.expected._source)
    }

    func testGetterHistoryAllExcept() {
        verify(srcContent: getterHistoryAllExcept._source,
               dstContent: getterHistoryAllExcept.expected._source)
    }

    func testGetterHistoryGetSet() {
        verify(srcContent: getterHistoryGetSet._source,
               dstContent: getterHistoryGetSet.expected._source)
    }

    func testGetterHistoryNonDefault() {
        verify(srcContent: getterHistoryNonDefault._source,
               dstContent: getterHistoryNonDefault.expected._source)
    }

    func testGetterHistoryOptionalGetOnly() {
        verify(srcContent: getterHistoryOptionalGetOnly._source,
               dstContent: getterHistoryOptionalGetOnly.expected._source)
    }

    func testGetterHistoryStatic() {
        verify(srcContent: getterHistoryStatic._source,
               dstContent: getterHistoryStatic.expected._source)
    }

    func testGetterHistoryGetSetOptOut() {
        verify(srcContent: getterHistoryGetSetOptOut._source,
               dstContent: getterHistoryGetSetOptOut.expected._source)
    }

    func testGetterHistoryExcludesCombineRxWrapperWeak() {
        verify(srcContent: getterHistoryExcludesCombineRxWrapperWeak._source,
               dstContent: getterHistoryExcludesCombineRxWrapperWeak.expected._source)
    }

    func testGetterHistoryRxSubjectEligible() {
        verify(srcContent: getterHistoryRxSubjectEligible._source,
               dstContent: getterHistoryRxSubjectEligible.expected._source)
    }

    // MARK: - Global flag (`--enable-getter-history`) cases

    func testGetterHistoryGlobalFlag() {
        verify(srcContent: getterHistoryGlobalFlag._source,
               dstContent: getterHistoryGlobalFlag.expected._source,
               enableGetterHistory: true)
    }

    func testGetterHistoryGlobalFlagOptOutWins() {
        verify(srcContent: getterHistoryGlobalFlagOptOut._source,
               dstContent: getterHistoryGlobalFlagOptOut.expected._source,
               enableGetterHistory: true)
    }

    func testGetterHistoryAllowSetCallCount() {
        verify(srcContent: getterHistoryAllowSetCallCount._source,
               dstContent: getterHistoryAllowSetCallCount.expected._source,
               allowSetCallCount: true)
    }

    func testGetterHistoryActorWithFlag() {
        verify(srcContent: getterHistoryActor._source,
               dstContent: getterHistoryActor.expected._source,
               enableGetterHistory: true)
    }

    // MARK: - No-op / guard cases

    func testGetterHistoryClassMockNoop() {
        verify(srcContent: getterHistoryClassMockNoop._source,
               dstContent: getterHistoryClassMockNoop.expected._source,
               declType: .classType,
               enableGetterHistory: true)
    }

    func testGetterHistoryProcessedMockMerge() {
        verify(srcContent: getterHistoryProcessedMockMerge._source,
               mockContent: getterHistoryProcessedMockMerge.parent._source,
               dstContent: getterHistoryProcessedMockMerge.expected._source,
               enableGetterHistory: true)
    }

    func testGetterHistoryOptionalClosureInitCollision() {
        verify(srcContent: getterHistoryOptionalClosureInitCollision._source,
               dstContent: getterHistoryOptionalClosureInitCollision.expected._source)
    }

    func testGetterHistoryEdgeTypes() {
        verify(srcContent: getterHistoryEdgeTypes._source,
               dstContent: getterHistoryEdgeTypes.expected._source)
    }

    // MARK: - Runtime behavior
    //
    // These instantiate the compiled `expected` fixture mocks directly. That's sound because the
    // matching string-diff tests above prove `expected == Mockolo's generated output`, so the
    // runtime behavior of the fixture mock is the runtime behavior of the generated mock.

    func testRuntimeGetterIncrementsOnRead() {
        let mock = getterHistoryGetSet.expected.GHGetSetMock()
        XCTAssertEqual(mock.sessionGetCallCount, 0)
        for expected in 1...3 {
            _ = mock.session
            XCTAssertEqual(mock.sessionGetCallCount, expected)
        }
        // Reads do not affect the setter counter.
        XCTAssertEqual(mock.sessionSetCallCount, 0)
    }

    func testRuntimeSetterIncrementsIndependently() {
        let mock = getterHistoryGetSet.expected.GHGetSetMock()
        mock.session = "a"
        mock.session = "b"
        XCTAssertEqual(mock.sessionSetCallCount, 2)
        // Writes do not affect the getter counter.
        XCTAssertEqual(mock.sessionGetCallCount, 0)
    }

    func testRuntimeInitDoesNotBumpCounters() {
        // Init writes the `_session` backing directly, so neither counter moves during initialization.
        let mock = getterHistoryGetSet.expected.GHGetSetMock(session: "seed")
        XCTAssertEqual(mock.sessionGetCallCount, 0)
        XCTAssertEqual(mock.sessionSetCallCount, 0)
        XCTAssertEqual(mock.session, "seed")
        XCTAssertEqual(mock.sessionGetCallCount, 1)
    }

    func testRuntimeGetOnlyIsStillStubbable() {
        // A tracked get-only property keeps its setter, so tests can stub it.
        let mock = getterHistorySpecific.expected.GHSpecificMock()
        mock.state = 42
        XCTAssertEqual(mock.stateGetCallCount, 0)
        XCTAssertEqual(mock.state, 42)
        XCTAssertEqual(mock.stateGetCallCount, 1)
    }
}

#if compiler(>=6.0)
extension GetterHistoryTests {
    func testGetterHistorySendable() {
        verify(srcContent: getterHistorySendable._source,
               dstContent: getterHistorySendable.expected._source,
               enableGetterHistory: true)
    }
}
#endif
