import Foundation

class ExistentialAnyTests: MockoloTestCase {
    func testForArgFuncs() {
        verify(srcContent: existentialAny,
               dstContent: existentialAnyMock)
    }

    func testExistentialAnyDefaultTypeMap() {
        verify(srcContent: existentialAnyDefaultTypeMap,
               dstContent: existentialAnyDefaultTypeMapMock)
    }
}
