import XCTest

final class MacroTests: MockoloTestCase {
    func testMacroInFunc() {
        verify(srcContent: macroInFunc,
               dstContent: macroInFuncMock)
    }

#if os(macOS)
    func testMacroInFuncWithOverload() {
        verify(srcContent: macroInFuncWithOverload,
               dstContent: macroInFuncWithOverloadMock)
    }
#endif

    func testMacroImports() {
        verify(srcContent: macroImports,
               dstContent: macroImportsMock)
    }

    func testMacroImportsWithOtherMacro() {
        verify(srcContent: macroImports,
               mockContent: parentMock,
               dstContent: macroImportsWithParentMock)
    }

    func testInheritedMacroImports() {
        verify(srcContent: macroImports,
               mockContent: parentWithMacroMock,
               dstContent: inheritedMacroImportsMock)
    }

    func testIfElseMacroImports() {
        verify(srcContent: ifElseMacroImports,
               dstContent: ifElseMacroImportsMock)
    }

    func testNestedMacroImports() {
        verify(srcContent: nestedMacroImports,
               dstContent: nestedMacroImportsMock)
    }
}
