import Foundation

class ReferenceTypesTests: MockoloTestCase {

    func testReferenceTypesWithWeakProperty() {
        verify(srcContent: referenceTypesWithWeakAnnotation,
               dstContent: referenceTypesWithWeakAnnotationMock)
    }


    func testReferenceTypesWithDynamicProperty() {
        verify(srcContent: referenceTypesWithDynamicAnnotation,
               dstContent: referenceTypesWithDynamicAnnotationMock)
    }
}
