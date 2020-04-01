import Foundation

class GenericFuncTests: MockoloTestCase {

    func testOptionalGenerics() {
        verify(srcContent: genericOptionalType,
               dstContent: genericOptionalTypeMock)
    }

    func testGenericFuncs() {
        verify(srcContent: genericFunc,
               dstContent: genericFuncMock)
    }
}


