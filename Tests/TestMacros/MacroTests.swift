import Foundation

class MacroTests: MockoloTestCase {
   func testMacro() {
        verify(srcContent: macro,
               dstContent: macroMock,
               parser: .swiftSyntax)
    }
}
