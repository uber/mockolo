import XCTest
import MockoloFramework

class MockoloTests: XCTestCase {
    
    let bundle = Bundle(for: MockoloTests.self)
    lazy var dstFilePath: String = {
        return bundle.bundlePath + "/Dst.swift"
    }()
    lazy var srcFilePath: String = {
        return bundle.bundlePath + "/Src.swift"
    }()
    lazy var mockFilePath: String = {
        return bundle.bundlePath + "/Mocks.swift"
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let created = FileManager.default.createFile(atPath: dstFilePath, contents: nil, attributes: nil)
        XCTAssert(created)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try? FileManager.default.removeItem(atPath: dstFilePath)
        try? FileManager.default.removeItem(atPath: srcFilePath)
        if FileManager.default.fileExists(atPath: mockFilePath) {
            try? FileManager.default.removeItem(atPath: mockFilePath)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSimpleVar() {
        verify(srcContent: simpleVar,
               dstContent: simpleVarMock)
    }
    
    func testNonSimpleVars() {
        verify(srcContent: nonSimpleVars,
               dstContent: nonSimpleVarsMock)
    }
    
    func testSimpleFunc() {
        verify(srcContent: simpleFunc,
               dstContent: simpleFuncMock)
    }
    
    func testSimpleDuplicates() {
        verify(srcContent: simpleDuplicates,
               dstContent: simpleDuplicatesMock)
    }
    
    func testDuplicates01() {
        verify(srcContent: duplicates1,
               dstContent: duplicateMock1)
    }
    
    func testDuplicates1() {
        verify(srcContent: duplicates1,
               dstContent: duplicateMock1)
    }
    
    func testDuplicates2() {
        verify(srcContent: duplicates2,
               dstContent: duplicatesMock2)
    }
    
    func testDuplicates3() {
        verify(srcContent: duplicates3,
               dstContent: duplicatesMock3)
    }
    
    func testDuplicateSigsInheritance1() {
        verify(srcContent: duplicateSigInheritance1,
               dstContent: duplicateSigInheritanceMock1)
    }
    
    func testDuplicateSigsInheritance2() {
        verify(srcContent: duplicateSigInheritance2,
               dstContent: duplicateSigInheritanceMock2)
    }
    
    func testDuplicateSigsInheritance3() {
        verify(srcContent: duplicateSigInheritance3,
               dstContent: duplicateSigInheritanceMock3)
    }
    
    func testDuplicateSigsInheritance4() {
        verify(srcContent: duplicateSigInheritance4,
               dstContent: duplicateSigInheritanceMock4)
    }
    
    func testDuplicateSigsInheritance5() {
        verify(srcContent: duplicateSigInheritance5,
               dstContent: duplicateSigInheritanceMock5)
    }
    
    func testGenericFuncs() {
        verify(srcContent: genericFunc,
               dstContent: genericFuncMock)
    }
    
    func testInheritedFuncs() {
        verify(srcContent: simpleInheritance,
               dstContent: simpleInheritanceMock)
    }
    
    func testDocComment1() {
        verify(srcContent: docComment1,
               dstContent: docCommentMock)
    }
    
    func testDocComment2() {
        verify(srcContent: docComment2,
               dstContent: docCommentMock)
    }
    
    func testTuplesBrackets() {
        verify(srcContent: tuplesBrackets,
               dstContent: tuplesBracketsMock)
    }
    
    func testFuncOverload() {
        verify(srcContent: overload,
               mockContent: overloadParent,
               dstContent: overloadMock)
    }
    
    func testFuncOverload1() {
        verify(srcContent: overload1,
               mockContent: overloadParent1,
               dstContent: overloadMock1)
    }
    
    func testHeader1() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright ©")
    }

    func testHeader2() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright ©©©")
    }

    func testHeader3() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock,
               header: "/// Copyright c")
    }

    func testEmojis() {
        verify(srcContent: emojiVars,
               mockContent: nonSimpleVarsMock,
               dstContent: emojiVarsMock)
    }
    
    func testInitParams() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock)
    }

    func testInitMethod() {
        verify(srcContent: protocolWithInit,
               mockContent: simpleInitParentMock,
               dstContent: protocolWithInitResultMock)
    }

    func testFuncThrows() {
        verify(srcContent: funcThrow,
               dstContent: funcThrowMock)
    }

    
    private func verify(srcContent: String, mockContent: String? = nil, dstContent: String, header: String = "") {
        let srcCreated = FileManager.default.createFile(atPath: srcFilePath, contents: srcContent.data(using: .utf8), attributes: nil)
        XCTAssert(srcCreated)

        let macroStart = String.poundIf + "MOCK"
        let macroEnd = String.poundEndIf
        
        let headerStr = header + String.headerDoc
        if let mockContent = mockContent {
            let formattedMockContent = """
            \(headerStr)
            \(macroStart)
            \(mockContent)
            \(macroEnd)
            """
            let mockCreated = FileManager.default.createFile(atPath: mockFilePath, contents: formattedMockContent.data(using: .utf8), attributes: nil)
            XCTAssert(mockCreated)
        }
        
        let formattedDstContent = """
        \(headerStr)
        \(macroStart)
        \(dstContent)
        \(macroEnd)
        """
        
        try? generate(sourceDirs: nil,
                      sourceFiles: [srcFilePath],
                      exclusionSuffixes: ["Mocks", "Tests"],
                      mockFilePaths: [mockFilePath],
                      annotatedOnly: false,
                      annotation: String.mockAnnotation,
                      header: header,
                      macro: "MOCK",
                      to: dstFilePath,
                      loggingLevel: 1,
                      concurrencyLimit: nil)
        let output = (try? String(contentsOf: URL(fileURLWithPath: dstFilePath), encoding: .utf8)) ?? ""
        let outputContents = output.components(separatedBy:  CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        let fixtureContents = formattedDstContent.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        XCTAssert(fixtureContents == outputContents)
    }
}
