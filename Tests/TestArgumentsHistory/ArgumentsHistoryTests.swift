import Foundation

class ArgumentsHistoryTests: MockoloTestCase {
    
    func testArgumentsHistoryWithAnnotationAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation,
               dstContent: argumentsHistoryWithAnnotationAllFuncCaseMock,
               captureAllFuncArgsHistory: true)
    }
        
    func testArgumentsHistoryWithAnnotationNotAllFuncCases() {
        verify(srcContent: argumentsHistoryWithAnnotation,
               dstContent: argumentsHistoryWithAnnotationNotAllFuncCaseMock,
               captureAllFuncArgsHistory: false)
    }
    
    func testArgumentsHistorySimpleCase() {
        verify(srcContent: argumentsHistorySimpleCase,
               dstContent: argumentsHistorySimpleCaseMock,
               captureAllFuncArgsHistory: true)
    }
    
    func testArgumentsHistoryInoutCase() {
        verify(srcContent: argumentsHistoryInoutCase,
               dstContent: argumentsHistoryInoutCaseMock,
               captureAllFuncArgsHistory: true)
    }
}
