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
import SourceKittenFramework

typealias ProtocolMapEntryType = (structure: Structure, file: File, models: [Model], attributes: [String])

public func generate(sourceDir: String?,
                     sourceFiles: [String]?,
                     excludeSuffixes: [String],
                     mockFilePaths: [String]?,
                     to outputFilePath: String,
                     concurrencyLimit: Int?,
                     parsingTimeout: Int,
                     retryParsingOnTimeoutLimit: Int,
                     shouldCollectParsingInfo: Bool) throws {
    
    assert(sourceDir != nil || sourceFiles != nil)
    
    var candidates = [String: String]()
    var parentMocks = [String: (Structure, File, [Model])]()
    var annotatedProtocolMap = [String: ProtocolMapEntryType]()
    var importLines = [String: [String]]()
    
    var sema: DispatchSemaphore? = nil
    if let limit = concurrencyLimit {
        sema = DispatchSemaphore(value: limit)
    }
    
    let mockgenQueue = DispatchQueue(label: "mockgen-q", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    
    let t0 = CFAbsoluteTimeGetCurrent()
    
    print("Build a map of input parent mocks and their ASTs, and a map of filepath and import lines...")
    if let mockFilePaths = mockFilePaths {
        // 1. Generate mapping for parent mocks and their ASTs specified in the input files,
        // while saving the import lines of the files being processed.
        _ = generateParentMocksMap(mockFilePaths,
                                   exclude: excludeSuffixes,
                                   semaphore: sema,
                                   timeout: parsingTimeout,
                                   queue: mockgenQueue) { (s: Structure, file: File, models: [Model]) in
                                    // Map between mock class names and their ASTs
                                    parentMocks[s.name] = (s, file, models)
                                    if let fpath = file.path, importLines[fpath] == nil {
                                        // Map between filepaths and import lines of the files.
                                        importLines[fpath] = file.lines(starting: ImportString)
                                    }
        }
    }
    
    let t1 = CFAbsoluteTimeGetCurrent()
    print("Took", t1-t0)
    
    print("Generate mocks for annotated protocols and store the results in a protocol map...")
    // 2. Generate mocks for annotated protocols in source dir and store the results in a map.
    _ = generateModelsForAnnotatedTypes(sourceDir: sourceDir,
                                        sourceFiles: sourceFiles,
                                        exclude: excludeSuffixes,
                                        semaphore: sema,
                                        timeout: parsingTimeout,
                                        queue: mockgenQueue) { (s: Structure, file: File, entites: [Model], attributes: [String]) in
                                            annotatedProtocolMap[s.name] = (s, file, entites, attributes)
                                            if let fpath = file.path, importLines[fpath] == nil {
                                                importLines[fpath] = file.lines(starting: ImportString)
                                            }
    }
    
    let t2 = CFAbsoluteTimeGetCurrent()
    print("Took", t2-t1)
    
    print("Accumulate the mock results for annotated protocols and their parents...")
    // 3. Accumulate mocks for annotated protocols and all of their parent protocols.
    _ = renderMocks(inheritanceMap: parentMocks,
                    annotatedProtocolMap: annotatedProtocolMap,
                    semaphore: sema,
                    queue: mockgenQueue,
                    process: {(s: Structure, file: File, mockString: String) in
                        candidates[s.name] = mockString
    })
    
    let t3 = CFAbsoluteTimeGetCurrent()
    print("Took", t3-t2)
    
    print("Put together mock results and import lines...")
    // 4. Accumulate import lines
    let imports = importLines.values.flatMap { $0 }
    let importsSet = Set(imports)
    let entities = candidates.values

    let ret = [HeaderDoc, PoundIfMock, importsSet.joined(separator: "\n"), entities.joined(separator: "\n"), PoundEndIf].joined(separator: "\n")
    
    let t4 = CFAbsoluteTimeGetCurrent()
    print("Took", t4-t3)
    
    print("Write the output to a file", outputFilePath)
    // 5. Write the final accumulated results to a file.
    _ = try? ret.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    
    let t5 = CFAbsoluteTimeGetCurrent()
    print("Took", t5-t4)
    
    print("TOTAL", t5-t0)
}

