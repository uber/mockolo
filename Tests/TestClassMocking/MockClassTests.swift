
import Foundation

class MockClassTests: MockoloTestCase {
    
    func testMockClass() {
        verify(srcContent: klass,
               dstContent: klassMock,
               declType: .classType)
    }
    
    func testMockClassWithParent() {
        verify(srcContent: klass,
               mockContent: klassParentMock,
               dstContent: klassLongerMock,
               declType: .classType)
    }

    func testMockClassInits() {
        verify(srcContent: klassInit,
               dstContent: klassInitMock,
               declType: .classType)
    }

    func testMockClassInitsWithParents() {
        verify(srcContent: klassInit,
               mockContent: klassInitParentMock,
               dstContent: klassInitLongerMock,
               declType: .classType)
    }
}

