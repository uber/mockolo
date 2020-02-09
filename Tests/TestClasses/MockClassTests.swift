
import Foundation

class MockClassTests: MockoloTestCase {
    
    func testMockClass() {
        verify(srcContent: klass,
               dstContent: klassMock)
    }
    
    func testMockClassWithParent() {
        verify(srcContent: klass,
               mockContent: klassParentMock,
               dstContent: klassLongerMock)
    }

    func testMockClassInits() {
        verify(srcContent: klassInit,
               dstContent: klassInitMock)
    }

    func testMockClassInitsWithParents() {
        verify(srcContent: klassInit,
               mockContent: klassInitParentMock,
               dstContent: klassInitLongerMock)
    }
}

