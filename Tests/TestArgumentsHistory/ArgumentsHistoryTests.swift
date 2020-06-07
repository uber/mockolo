import Foundation

class ArgumentsHistoryTests: MockoloTestCase {
    
    func testArgumentsHistoryWithAnnotationAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation,
               dstContent: argumentsHistoryWithAnnotationAllFuncCaseMock,
               enableFuncArgsHistory: true)
    }
        
    func testArgumentsHistoryWithAnnotationNotAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation,
               dstContent: argumentsHistoryWithAnnotationNotAllFuncCaseMock,
               enableFuncArgsHistory: false)
    }
    
    func testArgumentsHistorySimpleCase() {
        verify(srcContent: argumentsHistorySimpleCase,
               dstContent: argumentsHistorySimpleCaseMock,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryTupleCase() {
        verify(srcContent: argumentsHistoryTupleCase,
               dstContent: argumentsHistoryTupleCaseMock,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryGenericsCase() {
        verify(srcContent: argumentsHistoryGenericsCase,
               dstContent: argumentsHistoryGenericsCaseMock,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryInoutCase() {
        verify(srcContent: argumentsHistoryInoutCase,
               dstContent: argumentsHistoryInoutCaseMock,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryHandlerCase() {
        verify(srcContent: argumentsHistoryHandlerCase,
               dstContent: argumentsHistoryHandlerCaseMock,
               enableFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryStaticCase() {
        verify(srcContent: argumentsHistoryStaticCase,
               dstContent: argumentsHistoryStaticCaseMock,
               enableFuncArgsHistory: true)
    }
}
