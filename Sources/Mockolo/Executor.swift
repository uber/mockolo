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

class Executor {
    let defaultTimeout = 20
    
    // MARK: - Private
    private var loggingLevel: OptionArgument<Int>!
    private var outputFilePath: OptionArgument<String>!
    private var mockFilePaths: OptionArgument<[String]>!
    private var sourceDirs: OptionArgument<[String]>!
    private var sourceFiles: OptionArgument<[String]>!
    private var exclusionSuffixes: OptionArgument<[String]>!
    private var header: OptionArgument<String>!
    private var macro: OptionArgument<String>!
    private var annotation: OptionArgument<String>!
    private var annotatedOnly: OptionArgument<Bool>!
    private var concurrencyLimit: OptionArgument<Int>!
    private var version: OptionArgument<String>!
    
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
                                  shortName: "-v",
                                  kind: Int.self,
                                  usage: "The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error.")
        sourceFiles = parser.add(option: "--sourcefiles",
                                 shortName: "-srcs",
                                 kind: [String].self,
                                 usage: "List of source files (separated by a comma or a space) to generate mocks for. If no value is given, the --srcdir value will be used. If neither value is given, the program will exit. If both values are given, the --srcdir value will override.",
                                 completion: .filename)
        sourceDirs = parser.add(option: "--sourcedirs",
                                shortName: "-s",
                                kind: [String].self,
                                usage: "Path to the directories containing source files to generate mocks for. If no value is given, the --srcs value will be used. If neither value is given, the program will exit. If both values are given, the --srcdirs value will override.",
                                completion: .filename)
        mockFilePaths = parser.add(option: "--mockfiles",
                                   shortName: "-mocks",
                                   kind: [String].self,
                                   usage: "List of mock files (separated by a comma or a space) from modules this target depends on. ",
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
                                shortName: "-ant",
                                kind: String.self,
                                usage: "A custom annotation string used to indicate if a type should be mocked (default = @mockable).")
        annotatedOnly = parser.add(option: "--annotated-only",
                                   shortName: "-ant-only",
                                   kind: Bool.self,
                                   usage: "True if mock generation should be done on types that are annotated only, thus requiring all the types that the annotated type inherits to be also annotated. If set to false, the inherited types of the annotated types will also be considered for mocking. Default is set to true.")
        macro = parser.add(option: "--macro",
                                shortName: "-m",
                                kind: String.self,
                                usage: "If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.")
        header = parser.add(option: "--header",
                                shortName: "-h",
                                kind: String.self,
                                usage: "A custom header documentation to be added to the beginning of a generated mock file.")
        concurrencyLimit = parser.add(option: "--concurrency-limit",
                                      shortName: "-j",
                                      kind: Int.self,
                                      usage: "Maximum number of threads to execute concurrently (default = number of cores on the running machine).")
        version = parser.add(option: "--version",
                             kind: String.self,
                             usage: "Xcode version.")
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
        let annotation = arguments.get(self.annotation) ?? String.mockAnnotation
        let header = arguments.get(self.header)
        let annotatedOnly = arguments.get(self.annotatedOnly) ?? true
        let loggingLevel = arguments.get(self.loggingLevel) ?? 0
        let macro = arguments.get(self.macro)
        
        do {
            try generate(sourceDirs: srcDirs,
                         sourceFiles: srcs,
                         exclusionSuffixes: exclusionSuffixes,
                         mockFilePaths: mockFilePaths,
                         annotatedOnly: annotatedOnly,
                         annotation: annotation,
                         header: header,
                         macro: macro, 
                         to: outputFilePath,
                         loggingLevel: loggingLevel,
                         concurrencyLimit: concurrencyLimit)
        } catch {
            fatalError("Generation error: \(error)")
        }
    }
}
