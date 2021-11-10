import Foundation
import XCTest

class FuncAsyncTests: MockoloTestCase {
    override func setUpWithError() throws {
        super.setUpWithError()

#if swift(<5.5)
        throw XCTSkip("async/await support needs swift5.5")
#endif
    }

    func testFuncAsyncs() {
        verify(srcContent: funcAsync,
               dstContent: funcAsyncMock)
    }

    func testFuncAsyncThrows() {
        verify(srcContent: funcAsyncThrows,
               dstContent: funcAsyncThrowsMock)
    }
}
