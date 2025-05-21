import Foundation

class OpaqueTypeFuncTests: MockoloTestCase {
    func testOpaqueTypeParameterFuncs() {
        verify(srcContent: someParameterOptionalType._source,
               dstContent: someParameterOptionalType.expected._source)
    }

    func testOpaqueTypeMultiParameterFuncs() {
        verify(srcContent: someMultiParameterOptionalType._source,
               dstContent: someMultiParameterOptionalType.expected._source)
    }

    func testOpaqueTypeAsReturnTypeFuncs() {
        verify(srcContent: closureReturningSomeType._source,
               dstContent: closureReturningSomeType.expected._source)
    }
}
