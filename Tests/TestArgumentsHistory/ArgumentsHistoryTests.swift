import Foundation

class ArgumentsHistoryTests: MockoloTestCase {    
    func testArgumentsHistoryWithAnnotationAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation._source,
               dstContent: argumentsHistoryWithAnnotation.expected._source,
               enableFuncArgsHistory: true)
    }
        
    func testArgumentsHistoryWithAnnotationNotAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotationNotAllFuncCase._source,
               dstContent: argumentsHistoryWithAnnotationNotAllFuncCase.expected._source,
               enableFuncArgsHistory: false)
    }
    
    func testArgumentsHistorySimpleCase() {
        verify(srcContent: argumentsHistorySimpleCase._source,
               dstContent: argumentsHistorySimpleCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryTupleCase() {
        verify(srcContent: argumentsHistoryTupleCase._source,
               dstContent: argumentsHistoryTupleCase.expected._source,
               enableFuncArgsHistory: true)
    }

    func testArgumentsHistoryOverloadedCase() {
        verify(srcContent: argumentsHistoryOverloadedCase._source,
               dstContent: argumentsHistoryOverloadedCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryGenericsCase() {
        verify(srcContent: argumentsHistoryGenericsCase._source,
               dstContent: argumentsHistoryGenericsCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryInoutCase() {
        verify(srcContent: argumentsHistoryInoutCase._source,
               dstContent: argumentsHistoryInoutCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryHandlerCase() {
        verify(srcContent: argumentsHistoryHandlerCase._source,
               dstContent: argumentsHistoryHandlerCase.expected._source,
               enableFuncArgsHistory: true)
    }

    func testArgumentsHistoryEscapingTypealiasHandlerCase() {
        verify(srcContent: argumentsHistoryEscapingTypealiasHandlerCase._source,
               dstContent: argumentsHistoryEscapingTypealiasHandlerCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryAutoclosureCase() {
        verify(srcContent: argumentsHistoryAutoclosureCase._source,
               dstContent: argumentsHistoryAutoclosureCase.expected._source,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryStaticCase() {
        verify(srcContent: argumentsHistoryStaticCase._source,
               dstContent: argumentsHistoryStaticCase.expected._source,
               enableFuncArgsHistory: true)
    }

    func testArgumentsHistoryLabels() {
        verify(srcContent: argumentsHistoryLabels._source,
               dstContent: argumentsHistoryLabels.expected._source,
               enableFuncArgsHistory: true)
    }
}
