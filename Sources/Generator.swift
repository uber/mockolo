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

func generate(from srcDir: String,
              excludeSuffixes: [String],
              dependentFilePaths: [String],
              to outputFilePath: String,
              concurrencyLimit: Int?,
              parsingTimeout: Int,
              retryParsingOnTimeoutLimit: Int,
              shouldCollectParsingInfo: Bool) throws {
    
    var candidates = [String: String]()
    var parentMocks = [String: (Structure, File)]()
    var annotatedProtocolMap = [String: (Structure, File, [String])]()
    var importLines = [String: [String]]()
    let mockgenQueue = DispatchQueue(label: "mockgen-q", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    
    let t0 = CFAbsoluteTimeGetCurrent()
    print("Build a map of input mocks to be inherited...")
    _ = processDependentFiles(dependentFilePaths,
                              exclude: excludeSuffixes,
                              queue: mockgenQueue) { (s: Structure, file: File) in
                                if s.isClass, s.name.hasSuffix("Mock") {
                                    parentMocks[s.name] = (s, file)
                                    
                                    if let fpath = file.path, importLines[fpath] == nil {
                                        importLines[fpath] = processImports(file)
                                    }
                                }
    }
    
    _ = processMockTypeMap([srcDir], exclude: excludeSuffixes, queue: mockgenQueue) { (s: Structure, file: File, entites: [String]) in
        annotatedProtocolMap[s.name] = (s, file, entites)
    }
    
    let t1 = CFAbsoluteTimeGetCurrent()
    print("Took", t1-t0)
    
    print("Render a mock output for annotated protocols...")
    _ = processRendering([srcDir],
                         exclude: excludeSuffixes,
                         inheritanceMap: parentMocks,
                         annotatedProtocolMap: annotatedProtocolMap,
                         queue: mockgenQueue) { (s: Structure, file: File, mockString: String) in
                            candidates[s.name] = mockString
                            if let fpath = file.path, importLines[fpath] == nil {
                                importLines[fpath] = processImports(file)
                            }
    }
    
    let t2 = CFAbsoluteTimeGetCurrent()
    print("Took", t2-t1)
    
    print("Combine all of mock output into one...")
    let imports = importLines.values.flatMap{$0}
    let importsSet = Set(imports)
    
    let entities = candidates.map{$0.1}
    var ret = importsSet.joined(separator: "\n")
    ret.append("\n")
    ret.append(entities.joined())
    
    let t3 = CFAbsoluteTimeGetCurrent()
    print("Took", t3-t2)
    
    print("Write the output to a file...")
    _ = try? ret.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    
    let t4 = CFAbsoluteTimeGetCurrent()
    print("Took", t4-t3)
}
