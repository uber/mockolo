import Foundation

class FuncAsyncTests: MockoloTestCase {
    func testFuncAsyncs() {
        verify(srcContent: funcAsync,
               dstContent: funcAsyncMock)
    }

    func testFuncAsyncThrows() {
        verify(srcContent: funcAsyncThrows,
               dstContent: funcAsyncThrowsMock)
    }
}
