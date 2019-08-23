
import Foundation

class DocCommentTests: MockoloTestCase {
    
    func testDocComment1() {
        verify(srcContent: docComment1,
               dstContent: docCommentMock)
    }
    
    func testDocComment2() {
        verify(srcContent: docComment2,
               dstContent: docCommentMock)
    }
    
    func testDocCommentParent() {
        verify(srcContent: docComment1,
               mockContent: docCommentParentMock,
               dstContent: docCommentMock)
    }    
}
