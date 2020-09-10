import Foundation

class BasicFuncTests: MockoloTestCase {

    func testInoutParams() {
        verify(srcContent: inoutParams,
               dstContent: inoutParamsMock)
    }

    func testSubscripts() {
        verify(srcContent: subscripts,
               dstContent: subscriptsMocks)
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

    func testReturnSelfFunc() {
        verify(srcContent: returnSelfFunc,
               dstContent: returnSelfFuncMock)
    }
    
    
    func testSimpleFuncs() {
        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)
    }

    func testMockFuncs() {
        verify(srcContent: simpleFuncs,
               dstContent: simpleMockFuncMock,
               useTemplateFunc: true)
    }
}

