import Foundation

class NonSimpleVarTests: MockoloTestCase {
    
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
    
    func testRx() {
        verify(srcContent: rx,
               dstContent: rxMock,
               concurrencyLimit: nil)
    }

    func testRxMultiParents() {
           verify(srcContent: rxMultiParents,
                  dstContent: rxMultiParentsMock,
                  concurrencyLimit: nil)
    }

    func testRxVarInherited() {
        verify(srcContent: rxVarInherited,
               dstContent: rxVarInheritedMock,
               concurrencyLimit: nil)
    }

    func testRxVarSubjects() {
        verify(srcContent: rxVarSubjects,
               dstContent: rxVarSubjectsMock,
               concurrencyLimit: nil)
    }
    
    
}
