import Foundation

class OpaqueReturnTypeFuncTests: MockoloTestCase {

    func testOpaqueReturnTypeParamterFuncs() {
        verify(srcContent: someParameterOptionalType,
               dstContent: someParameterOptionalTypeMock)
    }

    func testOpaqueReturnTypeMultiParamterFuncs() {
        verify(srcContent: someMultiParameterOptionalType,
               dstContent: someMultiParameterOptionalTypeMock)
    }
}
