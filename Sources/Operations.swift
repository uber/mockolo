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

let AnnotationString = "@CreateMock"
let MockTypeString = "protocol "

let excludeList = ["Mock.swift",
                   "Mocks.swift",
                   "Test.swift",
                   "Tests.swift",
                   "Model.swift",
                   "Models.swift",
                   "Service.swift",
                   "Services.swift",
                   "NeedleGenerated.swift"]

extension String {
    var shouldFilter: Bool {
        
        for el in excludeList {
            if hasSuffix(el) {
                return false
            }
        }
        return shouldParse
        //            excludeList.filter{ contains($0) }.count == 0
    }
}

func renderMock(_ path: String,
                lock: NSLock? = nil,
                inputMocks: [String: (String, Structure)],
                process: (Structure, File, String) -> ()) -> Bool {
    let fileName = URL(fileURLWithPath: path).lastPathComponent
    // Filter out non-swift, tests, mocks, model files, etc.
    guard fileName.shouldFilter else { return false }
    guard let file = File(path: path) else { return false }
    if let topstructure = try? Structure(file: file) {
        for substructure in topstructure.substructures {
            var mockString = ""
            
            if substructure.isProtocol {
                let annotatedLinesInFile = file.lines.filter { (line: Line) -> Bool in
                    return line.content.contains(AnnotationString)
                }
                let currentLines = file.lines.filter { (line: Line) -> Bool in
                    if line.content.contains(substructure.name) {
                        let parts = line.content.components(separatedBy: MockTypeString)
                        let name = parts.last?.components(separatedBy: CharacterSet(charactersIn: ": {")).first
                        return name == substructure.name
                    }
                    return false
                }
                
                let annotatedLines = currentLines.filter { (line: Line) -> Bool in
                    return annotatedLinesInFile.contains(where: { (l: Line) -> Bool in
                        return l.index == line.index - 1
                    })
                }
                
                if annotatedLines.count > 0 {
                    
                    let parentMocks = substructure.inheritedTypes
                                        .filter { (parent: String) -> Bool in
                                            return (parent != "class" && parent != "Any" && parent != "AnyObject")
                                        }.map { (parent: String) -> String in
                                            let parentMockName = "\(parent)Mock"
                                            if let parentMockEntity = inputMocks[parentMockName] {
                                            let parentMockResult = parentMockEntity.1.extractPart(parentMockEntity.0)
                                            return parentMockResult
                                            }
                                            return ""
                                    }
                    
                    let children = substructure.substructures.map { (child: Structure) -> String in
                        return renderProperties(child)
                    }
                    
                    /// TODO: Add uninherited parent mocks as well to propagate down to child modules
                    mockString = """
                    class \(substructure.name)Mock: \(substructure.name) {
                    \(parentMocks.joined())
                    \(children.joined())
                    }
                    
                    """
                }
            }
            
            lock?.lock()
            process(substructure, file, mockString)
            lock?.unlock()
        }
        
        return true
    }
    
    return false
}

func processFiles(_ paths: [String],
                  queue: DispatchQueue?,
                  process: @escaping (Structure, File) -> ()) -> Int {
    var count = 0
    if let queue = queue {
        let lock = NSLock()
        
        for filePath in paths {
            queue.async {
                let result = fileParse(filePath, lock: lock, process: process)
                count += result ? 1 : 0
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        for filePath in paths {
            let result = fileParse(filePath, lock: nil, process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

func processRendering(_ paths: [String],
                      inputMocks: [String: (String, Structure)],
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
                                    process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

