import Foundation

class VarTests: MockoloTestCase {
    
    func testNonSimpleVars() {
        verify(srcContent: nonSimpleVars,
               dstContent: nonSimpleVarsMock)
    }
    
    func testSimpleVars() {
        verify(srcContent: simpleVars,
               dstContent: simpleVarsMock)
    }

    func testSimpleVarsWithFinal() {
        verify(srcContent: simpleVars,
               dstContent: simpleVarsFinalMock,
               mockFinal: true)
    }

    func testVarCallCounts() {
        verify(srcContent: simpleVars,
               dstContent: simpleVarsAllowCallCountMock,
               allowSetCallCount: true)
    }
}
