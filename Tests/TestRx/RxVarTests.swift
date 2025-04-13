import Foundation

class RxVarTests: MockoloTestCase {
    
    func testRx() {
        verify(srcContent: rx._source,
               dstContent: rx.expected._source)
    }

    func testRxMultiParents() {
        verify(srcContent: rxMultiParents._source,
               dstContent: rxMultiParents.expected._source)
    }

    func testRxVarInherited() {
        verify(srcContent: rxVarInherited._source,
               dstContent: rxVarInherited.expected._source)
    }

    func testRxObservables() {
        verify(srcContent: rxObservables._source,
               dstContent: rxObservables.expected._source)
    }

    func testRxSubjects() {
        verify(srcContent: rxSubjects._source,
               mockContent: rxSubjects.parent._source,
               dstContent: rxSubjects.expected._source)
    }
}
