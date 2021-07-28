import Foundation

class ModifiersTypesTests: MockoloTestCase {

    func testmodifiersTypesWithWeakProperty() {
        verify(srcContent: modifiersTypesWithWeakAnnotation,
               dstContent: modifiersTypesWithWeakAnnotationMock)
    }


    func testmodifiersTypesWithDynamicProperty() {
        verify(srcContent: modifiersTypesWithDynamicAnnotation,
               dstContent: modifiersTypesWithDynamicAnnotationMock)
    }

    func testmodifiersTypesWithDynamicFunc() {
        verify(srcContent: modifiersTypesWithDynamicFuncAnnotation,
               dstContent: modifiersTypesWithDynamicFuncAnnotationMock)
    }
}
