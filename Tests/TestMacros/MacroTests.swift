import Foundation

class MacroTests: MockoloTestCase {
   func testMacroInFunc() {
        verify(srcContent: macroInFunc,
               dstContent: macroInFuncMock,
               parser: .swiftSyntax)
    }

    func testMacroImports() {
         verify(srcContent: macroImports,
                dstContent: macroImportsMock,
                parser: .swiftSyntax)
     }
    
    func testMacroImportsWithOtherMacro() {
         verify(srcContent: macroImports,
                mockContent: parentMock,
                dstContent: macroImportsWithParentMock,
                parser: .swiftSyntax)
     }

    func testInheritedMacroImports() {
         verify(srcContent: macroImports,
                mockContent: parentWithMacroMock,
                dstContent: inheritedMacroImportsMock,
                parser: .swiftSyntax)
     }

    func testIfElseMacroImports() {
         verify(srcContent: ifElseMacroImports,
                dstContent: ifElseMacroImportsMock,
                parser: .swiftSyntax)
     }

    func testNestedMacroImports() {
         verify(srcContent: nestedMacroImports,
                dstContent: nestedMacroImportsMock,
                parser: .swiftSyntax)
     }

}
