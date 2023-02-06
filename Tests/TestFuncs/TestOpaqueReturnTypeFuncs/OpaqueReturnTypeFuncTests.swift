import Foundation

class OpaqueReturnTypeFuncTests: MockoloTestCase {

    func testOpaqueReturnTypeParamterFuncs() {
        verify(srcContent: someParameterOptionalType,
               dstContent: someParameterOptionalTypeMock)
    }
}
