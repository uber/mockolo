import Foundation

class OverloadTests: MockoloTestCase {
   
    func testInheritedFuncs() {
        verify(srcContent: simpleInheritance,
               dstContent: simpleInheritanceMock)
    }

    func testSimpleDuplicates() {
        verify(srcContent: simpleDuplicates,
               dstContent: simpleDuplicatesMock)
    }

    func testOverloadInParent() {
        verify(srcContent: overload1,
               mockContent: overloadParent1,
               dstContent: overloadMock1)
    }
    
    func testOverloadInParentAndChild() {
        verify(srcContent: overload2,
               mockContent: overloadParent2,
               dstContent: overloadMock2)
    }
    
    
    func testOverloadInChild() {
        verify(srcContent: overload3,
               dstContent: overloadMock3)
    }
    
    func testOverloadDifferentTypes() {
        verify(srcContent: overload4,
               dstContent: overloadMock4)
    }
    
    func testOverloadDifferentParamsAndTypes() {
        verify(srcContent: overload5,
               dstContent: overloadMock5)
    }
    
    func testOverloadDifferentParams() {
        verify(srcContent: overload6,
               dstContent: overloadMock6)
    }
    
    func testOverloadExtendedParams() {
        verify(srcContent: overload7,
               dstContent: overloadMock7)
    }
    
    func testVarFuncWithSameName() {
        verify(srcContent: sameNameVarFunc,
               dstContent: sameNameVarFuncMock)
    }
    
    func testOverloadExtendedParamsInParentAndChild() {
        verify(srcContent: overload8,
               dstContent: overloadMock8)
    }
    
    func testOverloadSameSigInParentAndChild() {
        verify(srcContent: overload9,
               dstContent: overloadMock9)
    }
    
    func testOverloadSameSigInMultiParents() {
        verify(srcContent: overload10,
               dstContent: overloadMock10)
    }
    
    func testOverloadPartialInParentAndChild() {
        verify(srcContent: overload11,
               dstContent: overloadMock11)
    }
    
}
