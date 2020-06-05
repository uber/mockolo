import Foundation

class ArgumentsHistoryTests: MockoloTestCase {
    
    func testArgumentsHistoryForAllFuncs() {
        verify(srcContent: argumentsHistoryForAllFuncs,
               dstContent: argumentsHistoryForAllFuncsMock,
               captureAllFuncArgsHistory: true)
    }
    
}
