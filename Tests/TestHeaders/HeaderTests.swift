
import Foundation

class HeaderTests: MockoloTestCase {
    
    
    func testHeader1() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright ©",
               parser: .swiftSyntax)
    }
    
    func testHeader2() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright ©©©")
    }
    
    func testHeader3() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright c")
    }
    
}
