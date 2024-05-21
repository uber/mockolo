import Foundation

class AsyncFunctionGlobalActorOverrideTests: MockoloTestCase {
    func testAsyncFunctionGlobalActorOverride() {
        verify(srcContent: asyncFunctionGlobalActorOverride, dstContent: asyncFunctionGlobalActorOverrideMock)
    }
}
