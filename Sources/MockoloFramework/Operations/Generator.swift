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

import CoreFoundation
import Foundation

enum InputError: Error {
    case annotationError
    case sourceFilesError
}

/// Performs end to end mock generation flow
public func generate(sourceDirs: [String],
                     sourceFiles: [String],
                     parser: SourceParser,
                     exclusionSuffixes: [String],
                     mockFilePaths: [String]?,
                     annotation: String,
                     header: String?,
                     macro: String?,
                     declType: DeclType,
                     useTemplateFunc: Bool,
                     useMockObservable: Bool,
                     allowSetCallCount: Bool,
                     enableFuncArgsHistory: Bool,
                     disableCombineDefaultValues: Bool,
                     mockFinal: Bool,
                     testableImports: [String],
                     customImports: [String],
                     excludeImports: [String],
                     to outputFilePath: String,
                     loggingLevel: Int,
                     concurrencyLimit: Int?,
                     onCompletion: @escaping (String) -> ()) throws {
    guard sourceDirs.count > 0 || sourceFiles.count > 0 else {
        log("Source files or directories do not exist", level: .error)
        throw InputError.sourceFilesError
    }
    
    scanConcurrencyLimit = concurrencyLimit
    minLogLevel = loggingLevel
    var candidates = [(String, Int64)]()
    var resolvedEntities = [ResolvedEntity]()
    var parentMocks = [String: Entity]()
    var protocolMap = [String: Entity]()
    var annotatedProtocolMap = [String: Entity]()
    var pathToContentMap = [(String, Data, Int64)]()
    var pathToImportsMap = ImportMap()
    var relevantPaths = [String]()

    signpost_begin(name: "Process input")
    let t0 = CFAbsoluteTimeGetCurrent()
    log("Process input mock files...", level: .info)
    if let mockFilePaths = mockFilePaths, !mockFilePaths.isEmpty {
        parser.parseProcessedDecls(mockFilePaths, fileMacro: macro) { (elements, imports) in
                                    elements.forEach { element in
                                        parentMocks[element.entityNode.name] = element
                                    }
                                    
                                    if let imports = imports {
                                        for (path, importMap) in imports {
                                            pathToImportsMap[path] = importMap
                                        }
                                    }
        }
    }
    signpost_end(name: "Process input")
    let t1 = CFAbsoluteTimeGetCurrent()
    log("Took", t1-t0, level: .verbose)
    
    signpost_begin(name: "Generate protocol map")
    log("Process source files and generate an annotated/protocol map...", level: .info)
    let paths = !sourceDirs.isEmpty ? sourceDirs : sourceFiles
    let isDirs = !sourceDirs.isEmpty
    parser.parseDecls(paths,
                      isDirs: isDirs,
                      exclusionSuffixes: exclusionSuffixes,
                      annotation: annotation,
                      fileMacro: macro,
                      declType: declType) { (elements, imports) in
                        elements.forEach { element in
                            protocolMap[element.entityNode.name] = element
                            if element.isAnnotated {
                                annotatedProtocolMap[element.entityNode.name] = element
                            }
                        }
                        if let imports = imports {
                            for (path, importMap) in imports {
                                pathToImportsMap[path] = importMap
                            }
                        }
    }
    signpost_end(name: "Generate protocol map")
    let t2 = CFAbsoluteTimeGetCurrent()
    log("Took", t2-t1, level: .verbose)
    
    let typeKeyList = [parentMocks.compactMap {$0.key.components(separatedBy: "Mock").first}, annotatedProtocolMap.map {$0.key}].flatMap{$0}
    var typeKeys = [String: String]()
    typeKeyList.forEach { (t: String) in
        typeKeys[t] = "\(t)Mock()"
    }
    Type.customTypeMap = typeKeys

    signpost_begin(name: "Generate models")
    log("Resolve inheritance and generate unique entity models...", level: .info)
    generateUniqueModels(protocolMap: protocolMap,
                         annotatedProtocolMap: annotatedProtocolMap,
                         inheritanceMap: parentMocks,
                         completion: { container in
                            pathToContentMap.append(contentsOf: container.imports)
                            resolvedEntities.append(container.entity)
                            relevantPaths.append(contentsOf: container.paths)
    })
    signpost_end(name: "Generate models")
    let t3 = CFAbsoluteTimeGetCurrent()
    log("Took", t3-t2, level: .verbose)
    
    signpost_begin(name: "Render models")
    log("Render models with templates...", level: .info)
    renderTemplates(entities: resolvedEntities,
                    useTemplateFunc: useTemplateFunc,
                    useMockObservable: useMockObservable,
                    allowSetCallCount: allowSetCallCount,
                    mockFinal: mockFinal,
                    enableFuncArgsHistory: enableFuncArgsHistory,
                    disableCombineDefaultValues: disableCombineDefaultValues
    ) { (mockString: String, offset: Int64) in
                        candidates.append((mockString, offset))
    }
    signpost_end(name: "Render models")
    let t4 = CFAbsoluteTimeGetCurrent()
    log("Took", t4-t3, level: .verbose)
     
    signpost_begin(name: "Write results")
    log("Write the mock results and import lines to", outputFilePath, level: .info)

    let imports = handleImports(pathToImportsMap: pathToImportsMap,
                                pathToContentMap: pathToContentMap,
                                customImports: customImports,
                                excludeImports: excludeImports,
                                testableImports: testableImports,
                                relevantPaths: relevantPaths)

    let result = try write(candidates: candidates,
                       header: header,
                       macro: macro,
                       imports: imports,
                       to: outputFilePath)
    signpost_end(name: "Write results")
    let t5 = CFAbsoluteTimeGetCurrent()
    log("Took", t5-t4, level: .verbose)
    
    let count = result.components(separatedBy: "\n").count
    log("TOTAL", t5-t0, level: .verbose)
    log("#Protocols = \(protocolMap.count), #Annotated protocols = \(annotatedProtocolMap.count), #Parent mock classes = \(parentMocks.count), #Final mock classes = \(candidates.count), File LoC = \(count)", level: .verbose)
    
    onCompletion(result)
}
