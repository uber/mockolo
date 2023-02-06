import Foundation

class OpaqueTypeFuncTests: MockoloTestCase {

    func testOpaqueTypeParamterFuncs() {
        verify(srcContent: someParameterOptionalType,
               dstContent: someParameterOptionalTypeMock)
    }

    func testOpaqueTypeMultiParamterFuncs() {
        verify(srcContent: someMultiParameterOptionalType,
               dstContent: someMultiParameterOptionalTypeMock)
    }
}
