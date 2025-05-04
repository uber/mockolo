final class MacroTests: MockoloTestCase {
    func testMacroInFunc() {
        verify(srcContent: macroInFunc,
               dstContent: macroInFuncMock)
    }

    func testMacroInFuncWithOverload() {
        verify(srcContent: macroInFuncWithOverload,
               dstContent: macroInFuncWithOverloadMock)
    }

    func testMacroElseIfInFunc() {
        verify(
            srcContent: macroElseIfInFunc,
            dstContent: macroElseIfInFuncMock
        )
    }

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
