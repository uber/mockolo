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
import Utility
import MockoloFramework

protocol Command {
    var name: String { get }
    func execute(with arguments: ArgumentParser.Result)
}

class Executor {
    let name: String
    let defaultTimeout = 30
    
    // MARK: - Private
    private var loggingLevel: OptionArgument<Int>!
    private var outputFilePath: OptionArgument<String>!
    private var mockFilePaths: OptionArgument<[String]>!
    private var sourceDirs: OptionArgument<[String]>!
    private var sourceFiles: OptionArgument<[String]>!
    private var exclusionSuffixes: OptionArgument<[String]>!
    private var annotatedOnly: OptionArgument<Bool>!
    private var concurrencyLimit: OptionArgument<Int>!
    private var parsingTimeout: OptionArgument<Int>!
    private var retryParsingOnTimeoutLimit: OptionArgument<Int>!
    private var shouldCollectParsingInfo: OptionArgument<Bool>!
    private var version: OptionArgument<String>!
    
    /// Initializer.
    ///
    /// - parameter name: The name used to check if this command should
    /// be executed.
    /// - parameter overview: The overview description of this command.
    /// - parameter parser: The argument parser to use.
    init(name: String, overview: String, parser: ArgumentParser) {
        self.name = name
        let subparser = parser.add(subparser: self.name, overview: overview)
        setupArguments(with: subparser)
    }
    
    /// Setup the arguments using the given parser.
    ///
    /// - parameter parser: The argument parser to use.
    private func setupArguments(with parser: ArgumentParser) {
        loggingLevel = parser.add(option: "--logging-level", shortName: "-v", kind: Int.self, usage: "The logging level to use. Default is set to 0 (info). Set 1 for verbose, 2 for warning, and 3 for error.")
        sourceFiles = parser.add(option: "--sourcefiles", shortName: "-srcs", kind: [String].self, usage: "List of source files (separated by a comma or a space) to generate mocks for. If no value is given, the --srcdir value will be used. If neither value is given, the program will exit. If both values are given, the --srcdir value will override.", completion: .filename)
        sourceDirs = parser.add(option: "--sourcedirs", shortName: "-srcdirs", kind: [String].self, usage: "Path to the directories containing source files to generate mocks for. If no value is given, the --srcs value will be used. If neither value is given, the program will exit. If both values are given, the --srcdirs value will override.", completion: .filename)
        mockFilePaths = parser.add(option: "--mockfiles", shortName: "-mocks", kind: [String].self, usage: "List of mock files (separated by a comma or a space) from modules this target depends on. ", completion: .filename)
        outputFilePath = parser.add(option: "--outputfile", shortName: "-output", kind: String.self, usage: "Output file path containing the generated Swift mock classes. If no value is given, the program will exit.", completion: .filename)
        exclusionSuffixes = parser.add(option: "--exclude-suffixes", shortName: "-exclude", kind: [String].self, usage: "List of filename suffix(es) without the file extensions to exclude from parsing (separated by a comma or a space).", completion: .filename)
        annotatedOnly = parser.add(option: "--annotated-only", shortName: "-antonly", kind: Bool.self, usage: "True if mock generation should be done on types that are annotated only, thus requiring all the types that the annotated type inherits to be also annotated. If set to false, the inherited types of the annotated types will also be considered for mocking. Default is set to true.")
        concurrencyLimit = parser.add(option: "--concurrency-limit", shortName: "-j", kind: Int.self, usage: "Maximum number of threads to execute concurrently (default = number of cores on the running machine).")
        parsingTimeout = parser.add(option: "--parsing-timeout", kind: Int.self, usage: "Timeout for parsing, in seconds (default = 10).")
        parsingTimeout = parser.add(option: "--rendering-timeout", kind: Int.self, usage: "Timeout for output rendering, in seconds (default = 15).")
        retryParsingOnTimeoutLimit = parser.add(option: "--retry-parsing-limit", kind: Int.self, usage: "Maximum retry numbers for parsing Swift source files in case of a timeout (default = 3).")
        shouldCollectParsingInfo = parser.add(option: "--collect-parsing-info", shortName: "-cpi", kind: Bool.self, usage: "True if info should be collected for parsing execution timeout errors.")
        version = parser.add(option: "--version", kind: String.self, usage: "Xcode version.")
    }
    
    /// Execute the command.
    ///
    /// - parameter arguments: The command line arguments to execute the command with.
    func execute(with arguments: ArgumentParser.Result) {

        guard let outputFilePath = arguments.get(outputFilePath) else { fatalError("Missing destination file path") }
        
        let srcDirs = arguments.get(sourceDirs)
        let srcs = arguments.get(sourceFiles)
        if sourceDirs == nil, srcs == nil {
            fatalError("Missing source files or their directory")
        }
        
        let exclusionSuffixes = arguments.get(self.exclusionSuffixes) ?? []
        let mockFilePaths = arguments.get(self.mockFilePaths) ?? []
        let concurrencyLimit = arguments.get(self.concurrencyLimit)
        let parsingTimeout = arguments.get(self.parsingTimeout) ?? defaultTimeout
        let retryParsingOnTimeoutLimit = arguments.get(self.retryParsingOnTimeoutLimit) ?? 0
        let shouldCollectParsingInfo = arguments.get(self.shouldCollectParsingInfo) ?? false
        let annotatedOnly = arguments.get(self.annotatedOnly) ?? true
        let loggingLevel = arguments.get(self.loggingLevel) ?? 0

        do {
            try generate(sourceDirs: srcDirs,
                         sourceFiles: srcs,
                         exclusionSuffixes: exclusionSuffixes,
                         mockFilePaths: mockFilePaths,
                         annotatedOnly: annotatedOnly,
                         to: outputFilePath,
                         loggingLevel: loggingLevel,
                         concurrencyLimit: concurrencyLimit,
                         parsingTimeout: parsingTimeout,
                         retryParsingOnTimeoutLimit: retryParsingOnTimeoutLimit,
                         shouldCollectParsingInfo: shouldCollectParsingInfo)
        } catch {
            fatalError("Generation error: \(error)")
        }
    }
}
