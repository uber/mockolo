import Foundation

class ExistentialAnyTests: MockoloTestCase {
    func testForArgFuncs() {
        verify(srcContent: existentialAny,
               dstContent: existentialAnyMock)
    }
}
