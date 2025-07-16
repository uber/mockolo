import XCTest
import MockoloFramework

class MockoloTestCase: XCTestCase {
    var srcFilePathsCount = 1
    var mockFilePathsCount = 1

    let bundle = Bundle(for: MockoloTestCase.self)

    lazy var defaultDstFilePath: String = {
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
        let created = FileManager.default.createFile(atPath: defaultDstFilePath, contents: nil, attributes: nil)
        XCTAssert(created)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try? FileManager.default.removeItem(atPath: defaultDstFilePath)
        for srcpath in srcFilePaths {
            try? FileManager.default.removeItem(atPath: srcpath)
        }
        for mockpath in mockFilePaths {
            try? FileManager.default.removeItem(atPath: mockpath)
        }
    }

    func verify(srcContent: String, mockContent: String? = nil, dstContent: String, header: String = "", declType: FindTargetDeclType = .protocolType, useTemplateFunc: Bool = false, testableImports: [String] = [], allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false, dstFilePath: String? = nil, concurrencyLimit: Int? = 1, disableCombineDefaultValues: Bool = false, file: StaticString = #filePath, line: UInt = #line) {
        let dstFilePath = dstFilePath ?? defaultDstFilePath
        var mockList: [String]?
        if let mock = mockContent {
            if mockList == nil {
                mockList = [String]()
            }
            mockList?.append(mock)
        }
        try? verify(srcContents: [srcContent], mockContents: mockList, dstContent: dstContent, header: header, declType: declType, useTemplateFunc: useTemplateFunc, testableImports: testableImports, allowSetCallCount: allowSetCallCount, mockFinal: mockFinal, enableFuncArgsHistory: enableFuncArgsHistory, dstFilePath: dstFilePath, concurrencyLimit: concurrencyLimit, disableCombineDefaultValues: disableCombineDefaultValues, file: file, line: line)
    }
    
    func verifyThrows(srcContent: String, mockContent: String? = nil, dstContent: String, header: String = "", declType: FindTargetDeclType = .protocolType, useTemplateFunc: Bool = false, testableImports: [String] = [], allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false, dstFilePath: String? = nil, concurrencyLimit: Int? = 1, disableCombineDefaultValues: Bool = false, errorHandler: (Error) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) {
        let dstFilePath = dstFilePath ?? defaultDstFilePath
        var mockList: [String]?
        if let mock = mockContent {
            if mockList == nil {
                mockList = [String]()
            }
            mockList?.append(mock)
        }
        XCTAssertThrowsError(
            try verify(srcContents: [srcContent], mockContents: mockList, dstContent: dstContent, header: header, declType: declType, useTemplateFunc: useTemplateFunc, testableImports: testableImports, allowSetCallCount: allowSetCallCount, mockFinal: mockFinal, enableFuncArgsHistory: enableFuncArgsHistory, dstFilePath: dstFilePath, concurrencyLimit: concurrencyLimit, disableCombineDefaultValues: disableCombineDefaultValues, file: file, line: line),
            "No error was thrown",
            errorHandler
        )
    }

    func verify(srcContents: [String], mockContents: [String]?, dstContent: String, header: String, declType: FindTargetDeclType, useTemplateFunc: Bool, testableImports: [String] = [], allowSetCallCount: Bool, mockFinal: Bool, enableFuncArgsHistory: Bool, dstFilePath: String, concurrencyLimit: Int?, disableCombineDefaultValues: Bool, file: StaticString = #filePath, line: UInt = #line) throws {
        var index = 0
        srcFilePathsCount = srcContents.count
        mockFilePathsCount = mockContents?.count ?? 0

        for src in srcContents {
            if index < srcContents.count {
                let srcCreated = FileManager.default.createFile(atPath: srcFilePaths[index], contents: src.data(using: .utf8), attributes: nil)
                index += 1
                XCTAssert(srcCreated, file: file, line: line)
            }
        }

        let macroStart = String.poundIf + "MOCK"
        let macroEnd = String.poundEndIf

        let headerStr = header + String.headerDoc
        if let mockContents {
            for (index, mockContent) in mockContents.enumerated() {
                let formattedMockContent = """
                \(headerStr)
                \(macroStart)
                \(mockContent)
                \(macroEnd)
                """
                let mockCreated = FileManager.default.createFile(atPath: mockFilePaths[index], contents: formattedMockContent.data(using: .utf8), attributes: nil)
                XCTAssert(mockCreated, file: file, line: line)
            }
        }

        try generate(sourceDirs: [],
                     sourceFiles: srcFilePaths,
                     parser: SourceParser(),
                     exclusionSuffixes: ["Mocks", "Tests"],
                     mockFilePaths: mockFilePaths,
                     annotation: String.mockAnnotation,
                     header: header,
                     macro: "MOCK",
                     declType: declType,
                     useTemplateFunc: useTemplateFunc,
                     allowSetCallCount: allowSetCallCount,
                     enableFuncArgsHistory: enableFuncArgsHistory,
                     disableCombineDefaultValues: disableCombineDefaultValues,
                     mockFinal: mockFinal,
                     testableImports: testableImports,
                     customImports: [],
                     excludeImports: [],
                     to: dstFilePath,
                     loggingLevel: 3,
                     concurrencyLimit: concurrencyLimit)
        let output = (try? String(contentsOf: URL(fileURLWithPath: self.defaultDstFilePath), encoding: .utf8)) ?? ""
        let outputContents = output.components(separatedBy:  .newlines).filter { !$0.isEmpty && !$0.allSatisfy(\.isWhitespace) }
        let fixtureContents = """
        \(headerStr)
        \(macroStart)
        \(dstContent)
        \(macroEnd)
        """.components(separatedBy: .newlines).filter { !$0.isEmpty && !$0.allSatisfy(\.isWhitespace) }
        if fixtureContents.isEmpty {
            throw XCTSkip("empty fixture", file: file, line: line)
        }

        let diff = lightDiff(old: outputContents, new: fixtureContents)
        if !diff.isEmpty {
            print("output:\n\(output)")
            XCTFail("diff:\n" + "\(diff)", file: file, line: line)
        }
    }
}

func lightDiff(old: [String], new: [String]) -> String {
    return old.difference(from: new)
        .sorted { l, r in
            return l.offset < r.offset
        }
        .map { change in
            switch change {
            case .remove(_, let element, _):
                return "- \(element)"
            case .insert(_, let element, _):
                return "+ \(element)"
            }
        }
        .joined(separator: "\n")
}

extension CollectionDifference.Change {
    var offset: Int {
        switch self {
        case .insert(let offset, _, _):
            return offset
        case .remove(let offset, _, _):
            return offset
        }
    }
}
