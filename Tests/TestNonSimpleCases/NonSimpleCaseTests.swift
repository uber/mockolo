import Foundation

class NonSimpleVarTests: MockoloTestCase {

    func testInoutParams() {
        verify(srcContent: inoutParams,
               dstContent: inoutParamsMock)
    }

    func testSubscripts() {
        verify(srcContent: subscripts,
               dstContent: subscriptsMocks,
               parser: .swiftSyntax)
    }
    

    func testNonSimpleVars() {
        verify(srcContent: nonSimpleVars,
               dstContent: nonSimpleVarsMock)
    }
    
    func testVariadicFuncs() {
        verify(srcContent: variadicFunc,
               dstContent: variadicFuncMock)
    }

    func testAutoclosureArgFuncs() {
        verify(srcContent: autoclosureArgFunc,
               dstContent: autoclosureArgFuncMock)
    }

    func testClosureArgFuncs() {
        verify(srcContent: closureArgFunc,
               dstContent: closureArgFuncMock)
    }

    func testForArgFuncs() {
        verify(srcContent: forArgClosureFunc,
               dstContent: forArgClosureFuncMock)
    }
}
