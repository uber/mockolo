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


/// Performs end to end mock generation flow

public let DefaultParsingTimeout = 10
public let DefaultRetryParsingLimit = 3

public func generate(sourceDirs: [String]?,
                     sourceFiles: [String]?,
                     exclusionSuffixes: [String],
                     mockFilePaths: [String]?,
                     annotatedOnly: Bool,
                     annotation: String,
                     to outputFilePath: String,
                     loggingLevel: Int,
                     concurrencyLimit: Int?,
                     parsingTimeout: Int,
                     retryParsingOnTimeoutLimit: Int,
                     shouldCollectParsingInfo: Bool) throws {
    
    assert(sourceDirs != nil || sourceFiles != nil)
    minLogLevel = loggingLevel
    var candidates = [(String, Int64)]()
    var parentMocks = [String: Entity]()
    var annotatedProtocolMap = [String: Entity]()
    var protocolMap = [String: Entity]()
    var processedImportLines = [String: [String]]()
    var pathToContentMap = [(String, String)]()
    var resolvedEntities = [ResolvedEntity]()
    
    var sema: DispatchSemaphore? = nil
    if let limit = concurrencyLimit {
        sema = DispatchSemaphore(value: limit)
    }
    
    let mockgenQueue = (concurrencyLimit ?? 0 == 1) ? nil :
        DispatchQueue(label: "mockgen-q", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    
    let t0 = CFAbsoluteTimeGetCurrent()
    log("Process input mock files...", level: .info)
    var processedMocksCount = 0
    if let mockFilePaths = mockFilePaths {
        processedMocksCount = generateProcessedTypeMap(mockFilePaths,
                                                       semaphore: sema,
                                                       timeout: parsingTimeout,
                                                       queue: mockgenQueue) { (elements, imports) in
                                                        elements.forEach { element in
                                                            parentMocks[element.name] = element
                                                            if processedImportLines[element.filepath] == nil {
                                                                processedImportLines[element.filepath] = imports
                                                            }
                                                        }
        }
    }
    
    let t1 = CFAbsoluteTimeGetCurrent()
    log("Took", t1-t0, "Input mocks:", processedMocksCount, level: .verbose)
    
    log("Process source files / Generate a protocol map & annotated protocol map...", level: .info)
    let entityCount = generateProtocolMap(sourceDirs: sourceDirs,
                                          sourceFiles: sourceFiles,
                                          exclusionSuffixes: exclusionSuffixes,
                                          annotatedOnly: annotatedOnly,
                                          annotation: annotation,
                                          semaphore: sema,
                                          timeout: parsingTimeout,
                                          queue: mockgenQueue) { (elements) in
                                            elements.forEach { element in
                                                protocolMap[element.name] = element
                                                if element.isAnnotated {
                                                    annotatedProtocolMap[element.name] = element
                                                }
                                            }
    }
    
    let t2 = CFAbsoluteTimeGetCurrent()
    log("Took", t2-t1, "#Generated entities:", entityCount, level: .verbose)
    
    let typeKeys = [parentMocks.compactMap {$0.key.components(separatedBy: "Mock").first}, annotatedProtocolMap.map {$0.key}].flatMap{$0}
    
    log("Resolve inheritance and generate unique entity models...", level: .info)
    generateUniqueModels(protocolMap: protocolMap,
                         annotatedProtocolMap: annotatedProtocolMap,
                         inheritanceMap: parentMocks,
                         typeKeys: typeKeys,
                         semaphore: sema,
                         timeout: parsingTimeout,
                         queue: mockgenQueue,
                         process: { (entity, pathsToContents) in
                            pathToContentMap.append(contentsOf: pathsToContents)
                            resolvedEntities.append(entity)
    })
    
    let t3 = CFAbsoluteTimeGetCurrent()
    log("Took", t3-t2, level: .verbose)
    
    log("Render models with templates...", level: .info)
    let renderedCount = renderTemplates(entities: resolvedEntities,
                                        typeKeys: typeKeys,
                                        semaphore: sema,
                                        timeout: parsingTimeout,
                                        queue: mockgenQueue,
                                        process: { (mockString: String, offset: Int64) in
                                            candidates.append((mockString, offset))
    })
    
    let t4 = CFAbsoluteTimeGetCurrent()
    log("Took", t4-t3, "Rendered:", renderedCount, level: .verbose)
    
    log("Write the mock results and import lines to", outputFilePath, level: .info)
    let result = write(candidates: candidates,
                       processedImportLines: processedImportLines,
                       pathToContentMap: pathToContentMap,
                       to: outputFilePath)
    
    let t5 = CFAbsoluteTimeGetCurrent()
    log("Took", t5-t4, level: .verbose)
    
    let count = result.components(separatedBy: "\n").count
    log("TOTAL:", t5-t0, "#Protocols = \(protocolMap.count), #Annotated protocols = \(annotatedProtocolMap.count), #Parent mock classes = \(parentMocks.count), #Final mock classes = \(candidates.count), File LoC = \(count)", level: .verbose)
}
