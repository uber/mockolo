import Foundation

class SimpleVarTests: MockoloTestCase {
    
    func testSimpleVars() {
        verify(srcContent: simpleVars,
               dstContent: simpleVarsMock)
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

    func testSimpleDuplicates() {
        verify(srcContent: simpleDuplicates,
               dstContent: simpleDuplicatesMock)
    }
    
    func testInheritedFuncs() {
        verify(srcContent: simpleInheritance,
               dstContent: simpleInheritanceMock)
    }
}
