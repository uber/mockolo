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

protocol Command {
    var name: String { get }
    func execute(with arguments: ArgumentParser.Result)
}

class GenerateCommand {
    let name: String
    let defaultTimeout = 30
    
    // MARK: - Private
    private var loggingLevel: OptionArgument<String>!
    private var outputFilePath: OptionArgument<String>!
    private var dependentFilePaths: OptionArgument<[String]>!
    private var sourceFilesDir: OptionArgument<String>!
    private var excludeSuffixes: OptionArgument<[String]>!
    private var concurrencyLimit: OptionArgument<Int>!
    private var parsingTimeout: OptionArgument<Int>!
    private var retryParsingOnTimeoutLimit: OptionArgument<Int>!
    private var shouldCollectParsingInfo: OptionArgument<Bool>!

    
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
        loggingLevel = parser.add(option: "--logging-level", shortName: "-lv", kind: String.self, usage: "The logging level to use.")
        sourceFilesDir = parser.add(option: "--source-files-dir", kind: String.self, usage: "The directory of the Swift source files to be processed for mock generation.", completion: .filename)
        dependentFilePaths = parser.add(option: "--dependent-filepaths", kind: [String].self, usage: "The directory of the Swift source files to be processed for mock generation.", completion: .filename)
        outputFilePath = parser.add(option: "--output-filepath", kind: String.self, usage: "Path to the destination file of generated Swift mock code.", completion: .filename)
        excludeSuffixes = parser.add(option: "--exclude-suffixes", kind: [String].self, usage: "Filename suffix(es) without extensions to exclude from parsing.", completion: .filename)
        concurrencyLimit = parser.add(option: "--concurrency-limit", kind: Int.self, usage: "The maximum number of tasks to execute concurrently.")
        parsingTimeout = parser.add(option: "--parsing-timeout", kind: Int.self, usage: "The timeout value, in seconds, to use for waiting on parsing tasks.")
        retryParsingOnTimeoutLimit = parser.add(option: "--retry-parsing-limit", kind: Int.self, usage: "The maximum number of times parsing Swift source files should be retried in case of timeouts.")
        shouldCollectParsingInfo = parser.add(option: "--collect-parsing-info", shortName: "-cpi", kind: Bool.self, usage: "Whether or not to collect information for parsing execution timeout errors.")
    }

    /// Execute the command.
    ///
    /// - parameter arguments: The command line arguments to execute the command with.
    func execute(with arguments: ArgumentParser.Result) {
        // TODO: add LoggingLevel
//        if let loggingLevelArg = arguments.get(loggingLevel), let loggingLevel = LoggingLevel.level(from: loggingLevelArg) {
//            set(minLoggingOutputLevel: loggingLevel)
//        }

        if let outputFilePath = arguments.get(outputFilePath) {
            if let sourceRootPaths = arguments.get(sourceFilesDir) {
                let excludeSuffixes = arguments.get(self.excludeSuffixes) ?? []
                let dependentFilePaths = arguments.get(self.dependentFilePaths) ?? []
                let concurrencyLimit = arguments.get(self.concurrencyLimit) ?? nil
                let parsingTimeout = arguments.get(self.parsingTimeout) ?? defaultTimeout
                let retryParsingOnTimeoutLimit = arguments.get(self.retryParsingOnTimeoutLimit) ?? 0
                let shouldCollectParsingInfo = arguments.get(self.shouldCollectParsingInfo) ?? false
                
                do {
                    // TODO: add sourcekitutilities to kill sourcekitd
                    try generate(from: sourceRootPaths,
                                 excludeSuffixes: excludeSuffixes,
                                 dependentFilePaths: dependentFilePaths,
                                 to: outputFilePath,
                                 concurrencyLimit: concurrencyLimit,
                                 parsingTimeout: parsingTimeout,
                                 retryParsingOnTimeoutLimit: retryParsingOnTimeoutLimit,
                                 shouldCollectParsingInfo: shouldCollectParsingInfo)
                } catch {
                    fatalError("Generation error: \(error)")
                }
            } else {
                fatalError("Missing source files directory.")
            }
        } else {
            fatalError("Missing destination file path.")
        }
    }
}
