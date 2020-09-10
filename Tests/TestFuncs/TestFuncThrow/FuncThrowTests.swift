import Foundation

class FuncThrowTests: MockoloTestCase {
    func testFuncThrows() {
        verify(srcContent: funcThrow,
               dstContent: funcThrowMock)
    }
}
