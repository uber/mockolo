class VarTests: MockoloTestCase {
    func testNonSimpleVars() {
        verify(srcContent: nonSimpleVars._source,
               dstContent: nonSimpleVars.expected._source)
    }
    
    func testSimpleVars() {
        verify(srcContent: simpleVars._source,
               dstContent: simpleVars.expected._source)
    }

    func testSimpleVarsWithFinal() {
        verify(srcContent: simpleVars._source,
               dstContent: simpleVars.addsFinalExpected._source,
               mockFinal: true)
    }

    func testVarCallCounts() {
        verify(srcContent: simpleVars._source,
               dstContent: simpleVars.allowsCallCountExpected._source,
               allowSetCallCount: true)
    }

#if compiler(>=6.0)
    func testAsyncThrows() {
        verify(srcContent: asyncThrowsVars._source,
               dstContent: asyncThrowsVars.expected._source)
    }

    func testThrowsNever() {
        verify(srcContent: throwsNeverVars._source,
               dstContent: throwsNeverVars.expected._source)
    }
#endif
}
