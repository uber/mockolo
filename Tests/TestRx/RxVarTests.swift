import Foundation

class RxVarTests: MockoloTestCase {
    
    func testRx() {
        verify(srcContent: rx,
               dstContent: rxMock,
               concurrencyLimit: nil)
    }

    func testRxMultiParents() {
           verify(srcContent: rxMultiParents,
                  dstContent: rxMultiParentsMock,
                  concurrencyLimit: nil)
    }

    func testRxVarInherited() {
        verify(srcContent: rxVarInherited,
               dstContent: rxVarInheritedMock,
               concurrencyLimit: nil)
    }

    func testRxVarSubjects() {
        verify(srcContent: rxVarSubjects,
               dstContent: rxVarSubjectsMock,
               concurrencyLimit: nil)
    }
    
    
}
