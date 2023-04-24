import Foundation

class OpaqueTypeFuncTests: MockoloTestCase {

    func testOpaqueTypeParameterFuncs() {
        verify(srcContent: someParameterOptionalType,
               dstContent: someParameterOptionalTypeMock)
    }

    func testOpaqueTypeMultiParameterFuncs() {
        verify(srcContent: someMultiParameterOptionalType,
               dstContent: someMultiParameterOptionalTypeMock)
    }
}
