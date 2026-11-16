import Foundation
import XCTest

class PerformanceTests: MockoloTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] == "1")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<5 {
                invoke(BasicFuncTests.testInoutParams, name: "testInoutParams")
                invoke(BasicFuncTests.testSubscripts, name: "testSubscripts")
                invoke(BasicFuncTests.testAutoclosureArgFuncs, name: "testAutoclosureArgFuncs")
                invoke(BasicFuncTests.testForArgFuncs, name: "testForArgFuncs")
                invoke(BasicFuncTests.testReturnSelfFunc, name: "testReturnSelfFunc")
                invoke(BasicFuncTests.testSimpleFuncs, name: "testReturnSelfFunc")
                invoke(BasicFuncTests.testSimpleFuncsAllowCallCount, name: "testSimpleFuncsAllowCallCount")

                invoke(OverloadTests.testOverloadPartialInParentAndChild, name: "testOverloadPartialInParentAndChild")
                invoke(OverloadTests.testOverloadSameSigInMultiParents, name: "testOverloadSameSigInMultiParents")
                invoke(OverloadTests.testOverloadSameSigInParentAndChild, name: "testOverloadSameSigInParentAndChild")
                invoke(OverloadTests.testOverloadExtendedParamsInParentAndChild, name: "testOverloadExtendedParamsInParentAndChild")
                invoke(OverloadTests.testOverloadDifferentParamsAndTypes, name: "testOverloadDifferentParamsAndTypes")
            }
        }
    }
}

fileprivate func invoke<Test: XCTestCase>(
    _ target: @escaping (Test) -> () -> (),
    name: String
) {
#if os(macOS)
    let testCase = Test.init(selector: Selector(name))
#else
    let testCase = Test.init(name: name, testClosure: { target($0 as! Test)() })
#endif
    testCase.invokeTest()
}
