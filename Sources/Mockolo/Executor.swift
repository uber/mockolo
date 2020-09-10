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
import TSCUtility
import MockoloFramework

class Executor {
    let defaultTimeout = 20
    
    // MARK: - Private
    private var loggingLevel: OptionArgument<Int>!
    private var outputFilePath: OptionArgument<String>!
    private var mockFileList: OptionArgument<String>!
    private var mockFilePaths: OptionArgument<[String]>!
    private var sourceDirs: OptionArgument<[String]>!
    private var sourceFiles: OptionArgument<[String]>!
    private var sourceFileList: OptionArgument<String>!
    private var exclusionSuffixes: OptionArgument<[String]>!
    private var header: OptionArgument<String>!
    private var macro: OptionArgument<String>!
    private var testableImports: OptionArgument<[String]>!
    private var customImports: OptionArgument<[String]>!
    private var excludeImports: OptionArgument<[String]>!
    private var annotation: OptionArgument<String>!
    private var useTemplateFunc: OptionArgument<Bool>!
    private var useMockObservable: OptionArgument<Bool>!
    private var mockAll: OptionArgument<Bool>!
    private var mockFinal: OptionArgument<Bool>!
    private var concurrencyLimit: OptionArgument<Int>!
    private var enableArgsHistory: OptionArgument<Bool>!

    /// Initializer.
    ///
    /// - parameter name: The name used to check if this command should
    /// be executed.
    /// - parameter overview: The overview description of this command.
    /// - parameter parser: The argument parser to use.
    init(parser: ArgumentParser) {
        setupArguments(with: parser)
    }
    
    /// Setup the arguments using the given parser.
    ///
    /// - parameter parser: The argument parser to use.
    private func setupArguments(with parser: ArgumentParser) {
        
        loggingLevel = parser.add(option: "--logging-level",
                                  shortName: "-l",
                                  kind: Int.self,
                                  usage: "The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error.")
        sourceFiles = parser.add(option: "--sourcefiles",
                                 shortName: "-srcs",
                                 kind: [String].self,
                                 usage: "List of source files (separated by a comma or a space) to generate mocks for. If the --sourcedirs or --filelist value exists, this will be ignored. ",
                                 completion: .filename)
        sourceFileList = parser.add(option: "--filelist",
                                 shortName: "-f",
                                 kind: String.self,
                                 usage: "Path to a file containing a list of source file paths (delimited by a new line). If the --sourcedirs value exists, this will be ignored. ",
                                 completion: .filename)
        sourceDirs = parser.add(option: "--sourcedirs",
                                shortName: "-s",
                                kind: [String].self,
                                usage: "Paths to the directories containing source files to generate mocks for. If the --filelist or --sourcefiles values exist, they will be ignored. ",
                                completion: .filename)
        mockFileList = parser.add(option: "--mock-filelist",
                                   kind: String.self,
                                   usage: "Path to a file containing a list of dependent files (separated by a new line) of modules this target depends on.",
                                   completion: .filename)
        mockFilePaths = parser.add(option: "--mockfiles",
                                   shortName: "-mocks",
                                   kind: [String].self,
                                   usage: "List of mock files (separated by a comma or a space) from modules this target depends on. If the --mock-filelist value exists, this will be ignored.",
                                   completion: .filename)
        outputFilePath = parser.add(option: "--destination",
                                    shortName: "-d",
                                    kind: String.self,
                                    usage: "Output file path containing the generated Swift mock classes. If no value is given, the program will exit.",
                                    completion: .filename)
        exclusionSuffixes = parser.add(option: "--exclude-suffixes",
                                       shortName: "-x",
                                       kind: [String].self,
                                       usage: "List of filename suffix(es) without the file extensions to exclude from parsing (separated by a comma or a space).",
                                       completion: .filename)
        annotation = parser.add(option: "--annotation",
                                shortName: "-a",
                                kind: String.self,
                                usage: "A custom annotation string used to indicate if a type should be mocked (default = @mockable).")
        macro = parser.add(option: "--macro",
                                shortName: "-m",
                                kind: String.self,
                                usage: "If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.")
        testableImports = parser.add(option: "--testable-imports",
                                        shortName: "-i",
                                        kind: [String].self,
                                        usage: "If set, @testable import statments will be added for each module name in this list.")
        customImports = parser.add(option: "--custom-imports",
                                        shortName: "-c",
                                        kind: [String].self,
                                        usage: "If set, custom module imports will be added to the final import statement list.")
        excludeImports = parser.add(option: "--exclude-imports",
                                        kind: [String].self,
                                        usage: "If set, listed modules will be exluded from the import statements in the mock output.")
        header = parser.add(option: "--header",
                                kind: String.self,
                                usage: "A custom header documentation to be added to the beginning of a generated mock file.")
        useTemplateFunc = parser.add(option: "--use-template-func",
                                 kind: Bool.self,
                                 usage: "If set, a common template function will be called from all functions in mock classes (default is set to false).")
        useMockObservable = parser.add(option: "--use-mock-observable",
                                 kind: Bool.self,
                                 usage: "If set, a property wrapper will be used to mock RxSwift Observable variables (default is set to false).")
        mockAll = parser.add(option: "--mock-all",
                                 kind: Bool.self,
                                 usage: "If set, it will mock all types (protocols and classes) with a mock annotation (default is set to false and only mocks protocols with a mock annotation).")
        mockFinal = parser.add(option: "--mock-final",
                                 kind: Bool.self,
                                 usage: "If set, generated mock classes will have the 'final' attributes (default is set to false).")
        concurrencyLimit = parser.add(option: "--concurrency-limit",
                                      shortName: "-j",
                                      kind: Int.self,
                                      usage: "Maximum number of threads to execute concurrently (default = number of cores on the running machine).")
        enableArgsHistory = parser.add(option: "--enable-args-history",
                                       kind: Bool.self,
                                       usage: "Whether to enable args history for all functions (default = false). To enable history per function, use the 'history' keyword in the annotation argument. ")
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
    
    
    /// Execute the command.
    ///
    /// - parameter arguments: The command line arguments to execute the command with.
    func execute(with arguments: ArgumentParser.Result) {
        guard let outputArg = arguments.get(outputFilePath) else { fatalError("Missing destination file path") }
        let outputFilePath = fullPath(outputArg)

        let srcDirs = arguments.get(sourceDirs)?.map(fullPath)
        var srcs: [String]?
        // If source file list exists, source files value will be overriden (see the usage in setupArguments above)
        if let srcList = arguments.get(sourceFileList) {
            let text = try? String(contentsOfFile: srcList, encoding: String.Encoding.utf8)
            srcs = text?.components(separatedBy: "\n").filter{!$0.isEmpty}.map(fullPath)
        } else {
            srcs = arguments.get(sourceFiles)?.map(fullPath)
        }

        if srcDirs == nil, srcs == nil {
            fatalError("Missing source files or directories")
        }
        
        var mockFilePaths: [String]?
        // First see if a list of mock files are stored in a file
        if let mockList = arguments.get(self.mockFileList) {
            let text = try? String(contentsOfFile: mockList, encoding: String.Encoding.utf8)
            mockFilePaths = text?.components(separatedBy: "\n").filter{!$0.isEmpty}.map(fullPath)
        } else {
            // If not, see if a list of mock files are directly passed in
            mockFilePaths = arguments.get(self.mockFilePaths)?.map(fullPath)
        }
        
        let concurrencyLimit = arguments.get(self.concurrencyLimit)
        let exclusionSuffixes = arguments.get(self.exclusionSuffixes) ?? []
        let annotation = arguments.get(self.annotation) ?? String.mockAnnotation
        let header = arguments.get(self.header)
        let loggingLevel = arguments.get(self.loggingLevel) ?? 0
        let macro = arguments.get(self.macro)
        let testableImports = arguments.get(self.testableImports)
        let customImports = arguments.get(self.customImports)
        let excludeImports = arguments.get(self.excludeImports)
        let shouldUseTemplateFunc = arguments.get(useTemplateFunc) ?? false
        let shouldUseMockObservable = arguments.get(useMockObservable) ?? false
        let shouldMockAll = arguments.get(mockAll) ?? false
        let shouldCaptureAllFuncArgsHistory = arguments.get(enableArgsHistory) ?? false
        let shouldMockFinal = arguments.get(mockFinal) ?? false

        do {
            try generate(sourceDirs: srcDirs,
                         sourceFiles: srcs,
                         parser: ParserViaSwiftSyntax(),
                         exclusionSuffixes: exclusionSuffixes,
                         mockFilePaths: mockFilePaths,
                         annotation: annotation,
                         header: header,
                         macro: macro,
                         declType: shouldMockAll ? .all : .protocolType,
                         useTemplateFunc: shouldUseTemplateFunc,
                         useMockObservable: shouldUseMockObservable,
                         enableFuncArgsHistory: shouldCaptureAllFuncArgsHistory,
                         mockFinal: shouldMockFinal,
                         testableImports: testableImports,
                         customImports: customImports,
                         excludeImports: excludeImports,
                         to: outputFilePath,
                         loggingLevel: loggingLevel,
                         concurrencyLimit: concurrencyLimit,
                         onCompletion: { _ in
                    log("Done. Exiting program.", level: .info)
                    exit(0)
            })
        } catch {
            fatalError("Generation error: \(error)")
        }
    }
}

public struct Version {
    /// The string value for this version.
    public let value: String

    /// The current Mockolo version.
    public static let current = Version(value: "1.2.8")
}
