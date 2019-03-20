import XCTest
import SwiftMockGenCore

class SwiftMockGenTests: XCTestCase {
    
    let bundle = Bundle(for: SwiftMockGenTests.self)
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
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDuplicateFuncNames() {
        verify(srcContent: duplicateFuncNames,
               dstContent: duplicateFuncNamesMock)
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
    
    func testInit() {
        verify(srcContent: simpleInit,
               mockContent: simpleInitParentMock,
               dstContent: simpleInitResultMock)
    }
    
    func testGenericFuncs() {
        verify(srcContent: genericFunc,
               dstContent: genericFuncMock)
    }
    
    func testSimpleDupes() {
        verify(srcContent: simpleDuplicates,
               dstContent: simpleDuplicatesMock)
    }
    func _testInheritedFuncs() {
        verify(srcContent: funcsInheritance,
               dstContent: funcsInheritanceMock)
    }
    func _testDuplicateInheritedFuncs() {
        verify(srcContent: duplicateFuncsInheritance,
               dstContent: duplicateFuncsInheritanceMock)
    }
    
    private func verify(srcContent: String, mockContent: String? = nil, dstContent: String) {
        let srcCreated = FileManager.default.createFile(atPath: srcFilePath, contents: srcContent.data(using: .utf8), attributes: nil)
        XCTAssert(srcCreated)
        if let mockContent = mockContent {
            let formattedMockContent = """
            \(String.headerDoc)
            \(String.poundIfMock)
            \(mockContent)
            \(String.poundEndIf)
            """
            let mockCreated = FileManager.default.createFile(atPath: mockFilePath, contents: formattedMockContent.data(using: .utf8), attributes: nil)
            XCTAssert(mockCreated)
        }
        
        let formattedDstContent = """
        \(String.headerDoc)
        \(String.poundIfMock)
        \(dstContent)
        \(String.poundEndIf)
       """
        
        try? generate(sourceDirs: nil,
                      sourceFiles: [srcFilePath],
                      excludeSuffixes: ["Mocks", "Tests"],
                      mockFilePaths: [mockFilePath],
                      to: dstFilePath)
        let output = (try? String(contentsOf: URL(fileURLWithPath: dstFilePath), encoding: .utf8)) ?? ""
        let outputContents = output.components(separatedBy:  CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        let fixtureContents = formattedDstContent.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter{!$0.isEmpty}
        XCTAssert(fixtureContents == outputContents)
    }
}
