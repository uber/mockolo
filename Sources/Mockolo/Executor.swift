//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import MockoloFramework
import ArgumentParser


struct Executor: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "mockolo", abstract: "Mockolo: Swift mock generator.")

    let defaultTimeout: Int

    // MARK: - Private
    @Flag(name: .long,
            help: "If set, generated *CallCount vars will be allowed to set manually.")
    private var allowSetCallCount: Bool = false

    @Option(help: "A custom annotation string used to indicate if a type should be mocked (default = @mockable).")
    private var annotation: String = String.mockAnnotation

    @Option(name: [.customShort("j"), .long],
            help: ArgumentHelp(
                "Maximum number of threads to execute concurrently (default = number of cores on the running machine).",
                valueName: "n"))
    private var concurrencyLimit: Int?

    @Option(help: "If set, custom module imports will be added to the final import statement list.")
    private var customImports: [String] = []

    @Flag(name: .long,
            help: "Whether to enable args history for all functions (default = false). To enable history per function, use the 'history' keyword in the annotation argument.")
    private  var enableArgsHistory: Bool = false

    @Option(name: .long,
            help: "If set, listed modules will be excluded from the import statements in the mock output.")
    private  var excludeImports: [String] = []

    @Option(name: [.customShort("x"), .customLong("exclude-suffixes")],
            help: "List of filename suffix(es) without the file extensions to exclude from parsing (separated by a comma or a space).",
            completion: .file())
    private var exclusionSuffixes: [String] = []

    @Option(name: .long,
            help: "A custom header documentation to be added to the beginning of a generated mock file.")
    private var header: String?

    private static let validLoggingLevels = [0, 1, 2, 3]
    @Option(name: [.short, .long],
            help: ArgumentHelp(
                "The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error.",
            valueName: "n"))
    private var loggingLevel: Int = 0

    @Option(help: "If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.")
    private var macro: String?

    @Flag(name: .long,
            help: "If set, it will mock all types (protocols and classes) with a mock annotation (default is set to false and only mocks protocols with a mock annotation).")
    private var mockAll: Bool = false

    @Option(name: .customLong("mock-filelist"),
            help: "Path to a file containing a list of dependent files (separated by a new line) of modules this target depends on.",
            completion: .file())
    private var mockFileList: String?

    @Flag(name: .long,
            help: "If set, generated mock classes will have the 'final' attributes (default is set to false).")
    private var mockFinal: Bool = false

    @Option(name: [.customLong("mocks", withSingleDash: true), .customLong("mockfiles")],
            help: "List of mock files (separated by a comma or a space) from modules this target depends on. If the --mock-filelist value exists, this will be ignored.",
            completion: .file())
    private var mockFilePaths: [String] = []

    @Option(name: [.customShort("d"), .customLong("destination")],
            help: "Output file path containing the generated Swift mock classes. If no value is given, the program will exit.",
            completion: .file())
    private var outputFilePath: String
    
    @Option(name: [.customShort("s"), .customLong("sourcedirs")],
            help: "Paths to the directories containing source files to generate mocks for. If the --filelist or --sourcefiles values exist, they will be ignored.",
            completion: .file())
    private var sourceDirs: [String] = []

    @Option(name: [.customShort("f"), .customLong("filelist")],
            help: "Path to a file containing a list of source file paths (delimited by a new line). If the --sourcedirs value exists, this will be ignored.",
            completion: .file())
    private var sourceFileList: String?

    @Option(name: [.customLong("srcs", withSingleDash: true), .customLong("sourcefiles")],
            help: "List of source files (separated by a comma or a space) to generate mocks for. If the --sourcedirs or --filelist value exists, this will be ignored.",
            completion: .file())
    private var sourceFiles: [String] = []

    @Option(name: [.long, .customShort("i")],
            help: "If set, @testable import statements will be added for each module name in this list.")
    private var testableImports: [String] = []

    @Flag(name: .long,
            help: "If set, a property wrapper will be used to mock RxSwift Observable variables (default is set to false).")
    private var useMockObservable: Bool = false

    @Flag(name: .long,
            help: "If set, a common template function will be called from all functions in mock classes (default is set to false).")
    private var useTemplateFunc: Bool = false
    
    init() {
        self.defaultTimeout = 20
    }
    
    private func fullPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return path
        }
        if path.hasPrefix("~") {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            return path.replacingOccurrences(of: "~", with: home, range: path.range(of: "~"))
        }
        return FileManager.default.currentDirectoryPath + "/" + path
    }

    mutating func validate() throws {
        guard Executor.validLoggingLevels.contains(loggingLevel) else {
            throw ValidationError("Please specify a valid logging level in the range: \(Executor.validLoggingLevels)")
        }

        srcDirs = self.sourceDirs.map(fullPath)

        // If source file list exists, source files value will be overriden (see the usage in setupArguments above)
        if let srcList = sourceFileList {
            let text = try? String(contentsOfFile: srcList, encoding: String.Encoding.utf8)
            srcs = text?.components(separatedBy: "\n").filter{!$0.isEmpty}.map(fullPath) ?? []
        } else {
            srcs = sourceFiles.map(fullPath)
        }

        if srcDirs.isEmpty && srcs.isEmpty {
            throw ValidationError("Missing source files or directories")
        }
    }

    // Source paths to be used in `run`
    private var srcDirs: [String] = []
    private var srcs: [String] = []

    mutating func run() throws {
        print("Start...")
        defer { print("Done.") }

        let outputFilePath = fullPath(self.outputFilePath)
        
        var mockFilePaths: [String]?
        // First see if a list of mock files are stored in a file
        if let mockList = self.mockFileList {
            let text = try? String(contentsOfFile: mockList, encoding: String.Encoding.utf8)
            mockFilePaths = text?.components(separatedBy: "\n").filter{!$0.isEmpty}.map(fullPath)
        } else {
            // If not, see if a list of mock files are directly passed in
            mockFilePaths = self.mockFilePaths.map(fullPath)
        }

        do {
            try generate(sourceDirs: srcDirs,
                         sourceFiles: srcs,
                         parser: SourceParser(),
                         exclusionSuffixes: exclusionSuffixes,
                         mockFilePaths: mockFilePaths,
                         annotation: annotation,
                         header: header,
                         macro: macro,
                         declType: mockAll ? .all : .protocolType,
                         useTemplateFunc: useTemplateFunc,
                         useMockObservable: useMockObservable,
                         allowSetCallCount: allowSetCallCount,
                         enableFuncArgsHistory: enableArgsHistory,
                         mockFinal: mockFinal,
                         testableImports: testableImports,
                         customImports: customImports,
                         excludeImports: excludeImports,
                         to: outputFilePath,
                         loggingLevel: loggingLevel,
                         concurrencyLimit: concurrencyLimit,
                         onCompletion: { _ in
                    log("Done. Exiting program.", level: .info)
            })
        } catch {
            fatalError("Generation error: \(error)")
        }
    }
}
