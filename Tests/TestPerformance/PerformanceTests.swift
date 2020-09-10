
import Foundation

class PerformanceTests: MockoloTestCase {
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<5 {
                let test1 = BasicFuncTests()
                test1.testInoutParams()
                test1.testSubscripts()
                test1.testVariadicFuncs()
                test1.testAutoclosureArgFuncs()
                test1.testClosureArgFuncs()
                test1.testForArgFuncs()
                test1.testReturnSelfFunc()
                
                let test2 = OverloadTests()
                test2.testOverloadPartialInParentAndChild()
                test2.testOverloadSameSigInMultiParents()
                test2.testOverloadSameSigInParentAndChild()
                test2.testOverloadExtendedParamsInParentAndChild()
                test2.testOverloadDifferentParamsAndTypes()
            }
        }
    }
}

