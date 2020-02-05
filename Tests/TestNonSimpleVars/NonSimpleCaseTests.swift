import Foundation

class NonSimpleVarTests: MockoloTestCase {
    
    func testSubscripts() {
        verify(srcContent: subscripts,
               dstContent: subscriptsMocks,
               useDefaultParser: true)
    }
    

    func testNonSimpleVars() {
        verify(srcContent: nonSimpleVars,
               dstContent: nonSimpleVarsMock)
    }
    
    func testRxVar() {
        verify(srcContent: rxVar,
               dstContent: rxVarMock,
               concurrencyLimit: nil)
    }
    
    func testVariadicFuncs() {
        verify(srcContent: variadicFunc,
               dstContent: variadicFuncMock,
               concurrencyLimit: nil)
    }

    func testAutoclosureArgFuncs() {
        verify(srcContent: autoclosureArgFunc,
               dstContent: autoclosureArgFuncMock,
               concurrencyLimit: nil)
    }

    func testClosureArgFuncs() {
        verify(srcContent: closureArgFunc,
               dstContent: closureArgFuncMock,
               concurrencyLimit: nil)
    }

    func testForArgFuncs() {
        verify(srcContent: forArgClosureFunc,
               dstContent: forArgClosureFuncMock,
               concurrencyLimit: nil)
    }
}
