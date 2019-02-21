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

func generateModelsForAnnotatedTypes(sourceDir: String?,
                                     sourceFiles: [String]?,
                                     exclude: [String]? = nil,
                                     semaphore: DispatchSemaphore?,
                                     timeout: Int,
                                     queue: DispatchQueue?,
                                     process: @escaping (Structure, File, [Model], [String]) -> ()) -> Int {
    if let sourceDir = sourceDir {
        return generateModels(dirs: [sourceDir], exclude: exclude, semaphore: semaphore, timeout: timeout, queue: queue, process: process)
    } else if let sourceFiles = sourceFiles {
        return generateModels(files: sourceFiles, exclude: exclude, semaphore: semaphore, timeout: timeout, queue: queue, process: process)
    }
    return -1
}

private func generateModels(files: [String],
                            exclude: [String]? = nil,
                            semaphore: DispatchSemaphore?,
                            timeout: Int,
                            queue: DispatchQueue?,
                            process: @escaping (Structure, File, [Model], [String]) -> ()) -> Int {
    var count = 0
    if let queue = queue {
        let lock = NSLock()
        for filePath in files {
            _ = semaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
            queue.async {
                let result = generateModelsToRender(filePath,
                                                    lock: lock,
                                                    exclude: exclude,
                                                    process: process)
                count += result ? 1 : 0
                semaphore?.signal()
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
        
    } else {
        for filePath in files {
            let result = generateModelsToRender(filePath,
                                                lock: nil,
                                                exclude: exclude,
                                                process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

private func generateModels(dirs: [String],
                            exclude: [String]? = nil,
                            semaphore: DispatchSemaphore?,
                            timeout: Int,
                            queue: DispatchQueue?,
                            process: @escaping (Structure, File, [Model], [String]) -> ()) -> Int {
    var count = 0
    
    if let queue = queue {
        let lock = NSLock()
        
        scanPaths(dirs) { filePath in
            _ = semaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
            queue.async {
                let result = generateModelsToRender(filePath,
                                                    lock: lock,
                                                    exclude: exclude,
                                                    process: process)
                count += result ? 1 : 0
                semaphore?.signal()
            }
        }
        
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        scanPaths(dirs) { filePath in
            let result = generateModelsToRender(filePath,
                                                lock: nil,
                                                exclude: exclude,
                                                process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}



// Render mocks for annotated protocols.
//
// @param process The completion handler which can store the rendered results in a protocol map
private func generateModelsToRender(_ path: String,
                                    lock: NSLock?,
                                    exclude: [String]? = nil,
                                    process: @escaping (Structure, File, [Model], [String]) -> ()) -> Bool {
    let fileName = URL(fileURLWithPath: path).lastPathComponent
    // Filter out non-swift files, tests, mocks, models, etc.
    guard fileName.shouldParse(with: exclude) else { return false }
    
    guard let file = File(path: path) else { return false }
    if let topstructure = try? Structure(file: file) {
        
        for substructure in topstructure.substructures {
            if substructure.isProtocol,
                // TODO: 1. Doc comment handling
                // A. Need to add linter to require all @CreateMock are preceded by /// (doc comment), and not CreateMocks.
                // B. Edge case: Add // or /// above the annotation line in case of preceding /*....  */ comments.
                substructure.isAnnotated(with: MockAnnotation, in: file.contents) {
                
                let childEntities = substructure.substructures.compactMap { (child: Structure) -> Model? in
                    return model(for: child, content: file.contents)
                }
                let childAttributes = substructure.substructures.compactMap { (child: Structure) -> [String]? in
                    return child.extractAttributes(file.contents, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
                    }.flatMap {$0}
                
                lock?.lock()
                process(substructure, file, childEntities, childAttributes)
                lock?.unlock()
            }
        }
        return true
    }
    return false
}
