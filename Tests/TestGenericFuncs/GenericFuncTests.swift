import Foundation

class GenericFuncTests: MockoloTestCase {
    
    func testGenericFuncs() {
        verify(srcContent: genericFunc,
               dstContent: genericFuncMock)
    }
}
