class ArgumentsHistoryTests: MockoloTestCase {
    func testArgumentsHistoryWithAnnotationAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation.source,
               dstContent: argumentsHistoryWithAnnotation.expected,
               enableFuncArgsHistory: true)
    }
        
    func testArgumentsHistoryWithAnnotationNotAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotationNotAllFuncCase.source,
               dstContent: argumentsHistoryWithAnnotationNotAllFuncCase.expected,
               enableFuncArgsHistory: false)
    }
    
    func testArgumentsHistorySimpleCase() {
        verify(srcContent: argumentsHistorySimpleCase.source,
               dstContent: argumentsHistorySimpleCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryTupleCase() {
        verify(srcContent: argumentsHistoryTupleCase.source,
               dstContent: argumentsHistoryTupleCase.expected,
               enableFuncArgsHistory: true)
    }

    func testArgumentsHistoryOverloadedCase() {
        verify(srcContent: argumentsHistoryOverloadedCase.source,
               dstContent: argumentsHistoryOverloadedCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryGenericsCase() {
        verify(srcContent: argumentsHistoryGenericsCase.source,
               dstContent: argumentsHistoryGenericsCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryInoutCase() {
        verify(srcContent: argumentsHistoryInoutCase.source,
               dstContent: argumentsHistoryInoutCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryHandlerCase() {
        verify(srcContent: argumentsHistoryHandlerCase.source,
               dstContent: argumentsHistoryHandlerCase.expected,
               enableFuncArgsHistory: true)
    }

    func testArgumentsHistoryEscapingTypealiasHandlerCase() {
        verify(srcContent: argumentsHistoryEscapingTypealiasHandlerCase.source,
               dstContent: argumentsHistoryEscapingTypealiasHandlerCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryAutoclosureCase() {
        verify(srcContent: argumentsHistoryAutoclosureCase.source,
               dstContent: argumentsHistoryAutoclosureCase.expected,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryStaticCase() {
        verify(srcContent: argumentsHistoryStaticCase.source,
               dstContent: argumentsHistoryStaticCase.expected,
               enableFuncArgsHistory: true)
    }
}
