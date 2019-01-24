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

typealias MockMap = (candidates: [String: String], parents: [String: String], parentMocks: [String: (String, Structure)])

func processImports(_ file: File) -> [String] {
    let imports = file.lines.filter { (line: Line) -> Bool in
        return line.content.trimmingCharacters(in: CharacterSet.whitespaces).starts(with: "import ")
        }.map { (line: Line) -> String in
            return line.content
    }
    return imports
}

func lookupEntities(name: String, inputMocks: [String: (Structure, File)], annotatedProtocolMap: [String: (Structure, File, [String])]) -> [String] {
   var result = [""]
    if let cur = annotatedProtocolMap[name] {
        let curStructure = cur.0
        let curEntities = cur.2
        result.append(contentsOf: curEntities)

        for parent in curStructure.inheritedTypes {
            if parent != "class", parent != "Any", parent != "AnyObject" {
                let parentResult = lookupEntities(name: parent, inputMocks: inputMocks, annotatedProtocolMap: annotatedProtocolMap)
                result.append(contentsOf: parentResult)
            }
        }
    } else if let val = inputMocks["\(name)Mock"] {
        let parentResult = val.0.extractPart(val.1.contents)
        result.append(parentResult)
    }
    
    return result
}

func renderMock(_ path: String,
                lock: NSLock? = nil,
                inputMocks: [String: (Structure, File)],
                exclude: [String]?,
                annotatedProtocolMap: [String: (Structure, File, [String])],
                process: (Structure, File, String) -> ()) -> Bool {
    let fileName = URL(fileURLWithPath: path).lastPathComponent
    // Filter out non-swift, tests, mocks, model files, etc.
    guard fileName.shouldParse(with: exclude) else { return false }
    guard let file = File(path: path) else { return false }
    if let topstructure = try? Structure(file: file) {
        for substructure in topstructure.substructures {
            var mockString = ""
            if substructure.isProtocol, annotatedProtocolMap[substructure.name] != nil {
                
                let result = lookupEntities(name: substructure.name, inputMocks: inputMocks, annotatedProtocolMap: annotatedProtocolMap)
                let resultSet = Set(result)
                
                /// TODO: if @available(..) is found in resultSet, add it to this (enclosing classs attributes)
                let attributeStr = substructure.extractAttributes(file.contents)?.joined(separator: " ") ?? ""
                
                /// TODO: Add uninherited public parent mocks as well to propagate down to child modules
                mockString = """
                
                \(attributeStr)
                \(substructure.accessControlLevelDescription) class \(substructure.name)Mock: \(substructure.name) {
                \(resultSet.joined(separator: "\n"))
                }
                
                """
                
                lock?.lock()
                process(substructure, file, mockString)
                lock?.unlock()
            }
        }
        return true
    }
    return false
}

func processFiles(_ paths: [String],
                  exclude: [String]? = nil,
                  queue: DispatchQueue?,
                  process: @escaping (Structure, File) -> ()) -> Int {
    var count = 0
    if let queue = queue {
        let lock = NSLock()
        
        for filePath in paths {
            queue.async {
                let result = fileParse(filePath, lock: lock, exclusionList: exclude, process: process)
                count += result ? 1 : 0
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        for filePath in paths {
            let result = fileParse(filePath, lock: nil, exclusionList: exclude, process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

func filterMockType(_ path: String,
                    lock: NSLock?,
                    exclude: [String]? = nil,
                    process: @escaping (Structure, File, [String]) -> ()) -> Bool {
    let fileName = URL(fileURLWithPath: path).lastPathComponent
    // Filter out non-swift, tests, mocks, model files, etc.
    guard fileName.shouldParse(with: exclude) else { return false }
    guard let file = File(path: path) else { return false }
    if let topstructure = try? Structure(file: file) {
        
        let allAnnotatedLinesInFile = file.lines.filter { (line: Line) -> Bool in
            return line.content.contains(AnnotationString)
            }.map{$0.index}
        guard allAnnotatedLinesInFile.count > 0 else { return false }
        
        let allDeclLines = file.lines.filter { (line: Line) -> Bool in
            line.content.trimmingCharacters(in: CharacterSet.whitespaces).hasPrefix(MockTypeString)
        }.map{$0.index}
        
        for substructure in topstructure.substructures {
            if substructure.isProtocol,
                let curLine = substructure.currentLine(in: file),
                curLine.isAnnotated(annotatedLines: allAnnotatedLinesInFile, declLines: allDeclLines) {
                let entities = substructure.substructures.map { (child: Structure) -> String in
                    return renderProperties(child, line: curLine, file: file)
                }
                
                lock?.lock()
                process(substructure, file, entities)
                lock?.unlock()
            }
        }
        
        return true
    }
    
    return false
}

func processMockTypeMap(_ paths: [String],
                        exclude: [String]? = nil,
                        queue: DispatchQueue?,
                        process: @escaping (Structure, File, [String]) -> ()) -> Int {
    var count = 0
    
    if let queue = queue {
        let lock = NSLock()
        
        scanPaths(paths) { filePath in
            queue.async {
                let result = filterMockType(filePath,
                                            lock: lock,
                                            exclude: exclude,
                                            process: process)
                count += result ? 1 : 0
            }
        }
        
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        scanPaths(paths) { filePath in
            let result = filterMockType(filePath,
                                        lock: nil,
                                        exclude: exclude,
                                        process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
    
}

func processRendering(_ paths: [String],
                      inputMocks: [String: (Structure, File)],
                      exclude: [String]?,
                      annotatedProtocolMap: [String: (Structure, File, [String])],
                      queue: DispatchQueue?,
                      process: @escaping (Structure, File, String) -> ()) -> Int {
    
    var count = 0
    
    if let queue = queue {
        let lock = NSLock()
        
        scanPaths(paths) { filePath in
            queue.async {
                let result = renderMock(filePath,
                                        lock: lock,
                                        inputMocks: inputMocks,
                                        exclude: exclude,
                                        annotatedProtocolMap: annotatedProtocolMap,
                                        process: process)
                count += result ? 1 : 0
            }
        }
        
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        scanPaths(paths) { filePath in
            let result = renderMock(filePath,
                                    lock: nil,
                                    inputMocks: inputMocks,
                                    exclude: exclude,
                                    annotatedProtocolMap: annotatedProtocolMap,
                                    process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

