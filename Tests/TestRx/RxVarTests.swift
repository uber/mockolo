import Foundation

class RxVarTests: MockoloTestCase {
    
    func testRx() {
        verify(srcContent: rx,
               dstContent: rxMock)
    }

    func testRxMultiParents() {
           verify(srcContent: rxMultiParents,
                  dstContent: rxMultiParentsMock)
    }

    func testRxVarInherited() {
        verify(srcContent: rxVarInherited,
               dstContent: rxVarInheritedMock)
    }

    func testRxVarSubjects() {
        verify(srcContent: rxVarSubjects,
               dstContent: rxVarSubjectsMock)
    }
}
