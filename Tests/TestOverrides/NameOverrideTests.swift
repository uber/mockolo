import Foundation

class NameOverrideTests: MockoloTestCase {
    func testNameOverride() {
        verify(srcContent: nameOverride, dstContent: nameOverrideMock)
    }
}
