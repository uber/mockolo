import Foundation
import XCTest

class BasicFuncTests: MockoloTestCase {

    func testInoutParams() {
        verify(srcContent: inoutParams,
               dstContent: inoutParamsMock)
    }

    func testSubscripts() {
        verify(srcContent: subscripts,
               dstContent: subscriptsMocks)
    }
    
    func testVariadicFuncs() {
        verify(srcContent: variadicFunc,
               dstContent: variadicFuncMock)
    }

    func testAutoclosureArgFuncs() {
        verify(srcContent: autoclosureArgFunc,
               dstContent: autoclosureArgFuncMock)
    }

    func testClosureArgFuncs() {
        verify(srcContent: closureArgFunc,
               dstContent: closureArgFuncMock)
    }

    func testForArgFuncs() {
        verify(srcContent: forArgClosureFunc,
               dstContent: forArgClosureFuncMock)
    }

    func testReturnSelfFunc() {
        verify(srcContent: returnSelfFunc,
               dstContent: returnSelfFuncMock)
    }
    
    
    func testSimpleFuncs() {
        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)
    }

    func testMockFuncs() {
        verify(srcContent: simpleFuncs,
               dstContent: simpleMockFuncMock,
               useTemplateFunc: true)
    }

    func testFileWriteBehavior() throws {
        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)

        let expectedAttributes = try FileManager.default.attributesOfItem(atPath: dstFilePath)
        let expectedCreationDate = (expectedAttributes[.creationDate] as! Date).timeIntervalSinceReferenceDate
        let expectedModificationDate = (expectedAttributes[.modificationDate] as! Date).timeIntervalSinceReferenceDate

        verify(srcContent: simpleFuncs,
               dstContent: simpleFuncsMock)

        let attributes = try FileManager.default.attributesOfItem(atPath: dstFilePath)
        let creationDate = (attributes[.creationDate] as! Date).timeIntervalSinceReferenceDate
        let modificationDate = (attributes[.modificationDate] as! Date).timeIntervalSinceReferenceDate

        XCTAssertEqual(creationDate, expectedCreationDate)
        XCTAssertEqual(modificationDate, expectedModificationDate)
    }
}

