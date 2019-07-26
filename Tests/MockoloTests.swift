import XCTest
import MockoloFramework

class MockoloTests: XCTestCase {
    var srcFilePathsCount = 1
    var mockFilePathsCount = 1

    let bundle = Bundle(for: MockoloTests.self)

    lazy var dstFilePath: String = {
        return bundle.bundlePath + "/Dst.swift"
    }()
    
    lazy var srcFilePaths: [String] = {
        var idx = 0
        var paths = [String]()
        let prefix = bundle.bundlePath + "/Src"
        let suffix = ".swift"
        while idx < srcFilePathsCount {
            let path = prefix + "\(idx)" + suffix
            paths.append(path)
            idx += 1
        }
        return paths
    }()
    
    lazy var mockFilePaths: [String] = {
        var idx = 0
        var paths = [String]()
        let prefix = bundle.bundlePath + "/Mocks"
        let suffix = ".swift"
        while idx < mockFilePathsCount {
            let path = prefix + "\(idx)" + suffix
            paths.append(path)
            idx += 1
        }
        return paths
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let created = FileManager.default.createFile(atPath: dstFilePath, contents: nil, attributes: nil)
        XCTAssert(created)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try? FileManager.default.removeItem(atPath: dstFilePath)
        for srcpath in srcFilePaths {
            try? FileManager.default.removeItem(atPath: srcpath)
        }
        for mockpath in mockFilePaths {
            try? FileManager.default.removeItem(atPath: mockpath)
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
    
    func testDuplicates4() {
        verify(srcContent: duplicates4,
               dstContent: duplicatesMock4)
    }

    func testDuplicates5() {
        verify(srcContent: duplicates5,
               dstContent: duplicatesMock5,
               concurrencyLimit: 1)
    }
    
    func testSameNameVarFunc() {
        verify(srcContent: sameVarFuncName,
               dstContent: sameVarFuncNameMock)
    }
    
    func testDuplicateSigsInheritance1() {
        verify(srcContent: duplicateSigInheritance1,
               dstContent: duplicateSigInheritanceMock1)
    }
    
    func testDuplicateSigsInheritance2() {
        verify(srcContent: duplicateSigInheritance2,
               dstContent: duplicateSigInheritanceMock2,
               concurrencyLimit: 1)
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

    func testDocCommentParent() {
        verify(srcContent: docComment1,
               mockContent: docCommentParentMock,
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
               dstContent: emojiVarsMock)
    }

    func testEmojisExtract() {
        verify(srcContent: emojiVars,
               mockContent: emojiParentMock,
               dstContent: emojiCombMock)
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


    func testPATDefaultType() {
        verify(srcContent: patDefaultType,
               dstContent: patDefaultTypeMock)
    }

    func testPATPartialOverrideTypealiases() {
        verify(srcContent: patPartialOverride,
               dstContent: patPartialOverrideMock)
    }

    func testPATOverrideTypealiases() {
        verify(srcContent: patOverride,
               dstContent: patOverrideMock)
    }
    
    func testPATNameCollisions() {
        verify(srcContent: patNameCollision,
               dstContent: patNameCollisionMock)
    }
    
   
    func testRxVar() {
        verify(srcContent: rxVar,
            dstContent: rxVarMock)
    }


    private func verify(srcContents: [String], mockContents: [String]? = nil, dstContent: String, header: String = "", concurrencyLimit: Int? = nil) {
        var index = 0
        srcFilePathsCount = srcContents.count
        mockFilePathsCount = mockContents?.count ?? 0

        for src in srcContents {
            if index < srcContents.count {
                let srcCreated = FileManager.default.createFile(atPath: srcFilePaths[index], contents: src.data(using: .utf8), attributes: nil)
                index += 1
                XCTAssert(srcCreated)
            }
        }

        let macroStart = String.poundIf + "MOCK"
        let macroEnd = String.poundEndIf
        
        let headerStr = header + String.headerDoc
        index = 0
        if let mockContents = mockContents {
            
            for mockContent in mockContents {
                
            let formattedMockContent = """
            \(headerStr)
            \(macroStart)
            \(mockContent)
            \(macroEnd)
            """
            let mockCreated = FileManager.default.createFile(atPath: mockFilePaths[index], contents: formattedMockContent.data(using: .utf8), attributes: nil)
                index += 1
            XCTAssert(mockCreated)
            }
        }
        
        let formattedDstContent = """
        \(headerStr)
        \(macroStart)
        \(dstContent)
        \(macroEnd)
        """
        
        try? generate(sourceDirs: nil,
                      sourceFiles: srcFilePaths,
                      exclusionSuffixes: ["Mocks", "Tests"],
                      mockFilePaths: mockFilePaths,
                      annotatedOnly: false,
                      annotation: String.mockAnnotation,
                      header: header,
                      macro: "MOCK",
                      to: dstFilePath,
                      loggingLevel: 3,
                      concurrencyLimit: concurrencyLimit,
                      onCompletion: { ret in
        let output = (try? String(contentsOf: URL(fileURLWithPath: self.dstFilePath), encoding: .utf8)) ?? ""
        let outputContents = output.components(separatedBy:  CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        let fixtureContents = formattedDstContent.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        XCTAssert(fixtureContents == outputContents)
        })
    }
    
    private func verify(srcContent: String, mockContent: String? = nil, dstContent: String, header: String = "", concurrencyLimit: Int? = nil) {
        var mockList: [String]?
        if let mock = mockContent {
            if mockList == nil {
                mockList = [String]()
            }
            mockList?.append(mock)
        }
        verify(srcContents: [srcContent], mockContents: mockList, dstContent: dstContent, header: header, concurrencyLimit: concurrencyLimit)
    }
}
