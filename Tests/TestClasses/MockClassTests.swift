
import Foundation

class MockClassTests: MockoloTestCase {
    
    func testMockClass() {
        verify(srcContent: klass,
               dstContent: klassMock,
               useDefaultParser: true)
    }
    
    func testMockClassWithParent() {
        verify(srcContent: klass,
               mockContent: klassParentMock,
               dstContent: klassLongerMock,
               useDefaultParser: true)
    }
}
