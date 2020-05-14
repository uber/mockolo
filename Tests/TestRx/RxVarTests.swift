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

    func testRxMultiParentsMockObservable() {
           verify(srcContent: rxMultiParents,
                  dstContent: rxMultiParentsMockObservable,
                  useMockObservable: true)
    }

    func testRxVarInherited() {
        verify(srcContent: rxVarInherited,
               dstContent: rxVarInheritedMock)
    }

    func testRxObservables() {
        verify(srcContent: rxObservables,
               dstContent: rxObservablesMock)
    }

    func testRxSubjects() {
        verify(srcContent: rxSubjects,
               mockContent: rxSubjectsParent,
               dstContent: rxSubjectsMock)
    }
}
