import Foundation

class RxVarTests: MockoloTestCase {
    
    func testRx() {
        verify(srcContent: rxTaskRouting._source,
               dstContent: rxTaskRouting.expected._source)
    }

    func testRxMultiParents() {
        verify(srcContent: rxMultiParents._source,
               dstContent: rxMultiParents.expected._source)
    }

    func testRxVarInherited() {
        verify(srcContent: rxInherited._source,
               dstContent: rxInherited.expected._source)
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
