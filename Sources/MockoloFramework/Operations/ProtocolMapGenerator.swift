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

/// Performs protocol and annotated protocol map generation

func generateProtocolMap(sourceDirs: [String]?,
                         sourceFiles: [String]?,
                         exclusionSuffixes: [String]? = nil,
                         annotatedOnly: Bool,
                         annotation: Data,
                         semaphore: DispatchSemaphore?,
                         queue: DispatchQueue?,
                         process: @escaping ([Entity]) -> ()) {
    if let sourceDirs = sourceDirs {
        generateProtcolMap(dirs: sourceDirs, exclusionSuffixes: exclusionSuffixes, annotatedOnly: annotatedOnly, annotation: annotation, semaphore: semaphore, queue: queue, process: process)
    } else if let sourceFiles = sourceFiles {
        generateProtcolMap(files: sourceFiles, exclusionSuffixes: exclusionSuffixes, annotatedOnly: annotatedOnly, annotation: annotation,semaphore: semaphore, queue: queue, process: process)
    }
}

private func generateProtcolMap(dirs: [String],
                                exclusionSuffixes: [String]? = nil,
                                annotatedOnly: Bool,
                                annotation: Data,
                                semaphore: DispatchSemaphore?,
                                queue: DispatchQueue?,
                                process: @escaping ([Entity]) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        
        scanPaths(dirs) { filePath in
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                generateProtcolMap(filePath,
                                   exclusionSuffixes: exclusionSuffixes,
                                   annotatedOnly: annotatedOnly,
                                   annotation: annotation,
                                   lock: lock,
                                   process: process)
                semaphore?.signal()
            }
        }
        
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        scanPaths(dirs) { filePath in
            generateProtcolMap(filePath,
                               exclusionSuffixes: exclusionSuffixes,
                               annotatedOnly: annotatedOnly,
                               annotation: annotation,
                               lock: nil,
                               process: process)
        }
    }
}


private func generateProtcolMap(files: [String],
                                exclusionSuffixes: [String]? = nil,
                                annotatedOnly: Bool,
                                annotation: Data,
                                semaphore: DispatchSemaphore?,
                                queue: DispatchQueue?,
                                process: @escaping ([Entity]) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        for filePath in files {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                generateProtcolMap(filePath,
                                   exclusionSuffixes: exclusionSuffixes,
                                   annotatedOnly: annotatedOnly,
                                   annotation: annotation,
                                   lock: lock,
                                   process: process)
                semaphore?.signal()
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
        
    } else {
        for filePath in files {
            generateProtcolMap(filePath,
                               exclusionSuffixes: exclusionSuffixes,
                               annotatedOnly: annotatedOnly,
                               annotation: annotation,
                               lock: nil,
                               process: process)
        }
    }
}

private func generateProtcolMap(_ path: String,
                                exclusionSuffixes: [String]? = nil,
                                annotatedOnly: Bool,
                                annotation: Data,
                                lock: NSLock?,
                                process: @escaping ([Entity]) -> ()) {
    
    guard path.shouldParse(with: exclusionSuffixes) else { return }
    guard let content = FileManager.default.contents(atPath: path) else {
        fatalError("Retrieving contents of \(path) failed")
    }
    
    if annotatedOnly, content.range(of: annotation) == nil {
        return
    }
    
    do {
        let topstructure = try Structure(path: path)
        var results = [Entity]()
        for current in topstructure.substructures {
            if current.isProtocol {
                let metadata = current.annotationMetadata(with: annotation, in: content)
                let isAnnotated = metadata != nil
                
                if !annotatedOnly || isAnnotated {
                    let node = Entity(name: current.name,
                                      filepath: path,
                                      data: content,
                                      ast: current,
                                      isAnnotated: isAnnotated,
                                      metadata: metadata?.typealiases,
                                      isProcessed: false)
                    results.append(node)
                }
            }
        }
        
        lock?.lock()
        process(results)
        lock?.unlock()
        
    } catch {
        fatalError(error.localizedDescription)
    }
}
