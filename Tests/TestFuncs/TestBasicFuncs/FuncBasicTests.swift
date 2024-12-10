class BasicFuncTests: MockoloTestCase {
    func testInoutParams() {
        verify(srcContent: inoutParams._source,
               dstContent: inoutParams.expected._source)
    }

    func testSubscripts() {
        verify(srcContent: subscripts._source,
               dstContent: subscripts.expected._source)
    }
    
    func testVariadicFuncs() {
        verify(srcContent: variadicFunc._source,
               dstContent: variadicFunc.expected._source)
    }

    func testAutoclosureArgFuncs() {
        verify(srcContent: autoclosureArgFunc._source,
               dstContent: autoclosureArgFunc.expected._source)
    }

    func testClosureArgFuncs() {
        verify(srcContent: closureArgFunc._source,
               dstContent: closureArgFunc.expected._source)
    }

    func testForArgFuncs() {
        verify(srcContent: forArgClosureFunc._source,
               dstContent: forArgClosureFunc.expected._source)
    }

    func testReturnSelfFunc() {
        verify(srcContent: returnSelfFunc._source,
               dstContent: returnSelfFunc.expected._source)
    }
    
    
    func testSimpleFuncs() {
        verify(srcContent: simpleFuncs._source,
               dstContent: simpleFuncs.expected._source)
    }

    func testSimpleFuncsAllowCallCount() {
        verify(srcContent: simpleFuncs._source,
               dstContent: simpleFuncs.allowCallCountExpected._source,
               allowSetCallCount: true)
    }
    func testMockFuncs() {
        verify(srcContent: simpleFuncs._source,
               dstContent: simpleFuncs.mockFuncExpected._source,
               useTemplateFunc: true)
    }
}

