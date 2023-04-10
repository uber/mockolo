import Foundation

#if compiler(>=5.5.2) && canImport(_Concurrency)
final class ObjectTypesTests: MockoloTestCase {

    func testObjectTypesWithNoProperty() {
        verify(srcContent: argumentsObjectTypesWithNoAnnotation,
               dstContent: argumentsObjectTypesWithClassAnnotationMock)
    }

    func testObjectTypesWithClassProperty() {
        verify(srcContent: argumentsObjectTypesWithClassAnnotation,
               dstContent: argumentsObjectTypesWithClassAnnotationMock)
    }

    func testObjectTypesWithActorProperty() {
        verify(srcContent: argumentsObjectTypesWithActorAnnotation,
               dstContent: argumentsObjectTypesWithActorAnnotationMock)
    }
}
#endif
