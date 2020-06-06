import Foundation

class ArgumentsHistoryTests: MockoloTestCase {
    
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
