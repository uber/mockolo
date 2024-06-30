import Foundation

class FuncThrowTests: MockoloTestCase {
    func testFuncThrows() {
        verify(srcContent: funcThrow,
               dstContent: funcThrowMock)
    }

	func testTypedThrows() {
		verify(
			srcContent: funcTypedThrow,
			dstContent: funcTypedThrowMock
		)
	}
}
