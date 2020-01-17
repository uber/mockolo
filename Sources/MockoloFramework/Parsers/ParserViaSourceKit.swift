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

public class ParserViaSourceKit: SourceParsing {
    
    public init() {}
    
    /// Performs processed mock type map generation
    public func parseClasses(_ paths: [String],
                             semaphore: DispatchSemaphore?,
                             queue: DispatchQueue?,
                             process: @escaping ([Entity], [String: [String]]) -> ()) {
        
        if let queue = queue {
            let lock = NSLock()
            
            for filePath in paths {
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    self.generateProcessedModels(filePath, lock: lock, process: process)
                    semaphore?.signal()
                }
            }
            // Wait for queue to drain
            queue.sync(flags: .barrier) {}
        } else {
            for filePath in paths {
                generateProcessedModels(filePath, lock: nil, process: process)
            }
        }
    }
    
    /// Performs protocol and annotated protocol map generation
    public func parseProtocols(_ paths: [String]?,
                               isDirs: Bool,
                        exclusionSuffixes: [String]? = nil,
                        annotation: String,
                        semaphore: DispatchSemaphore?,
                        queue: DispatchQueue?,
                        process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let paths = paths else { return }
        if isDirs {
            generateProtcolMap(dirs: paths, exclusionSuffixes: exclusionSuffixes, annotation: annotation, semaphore: semaphore, queue: queue, process: process)
        } else {
            generateProtcolMap(files: paths, exclusionSuffixes: exclusionSuffixes, annotation: annotation, semaphore: semaphore, queue: queue, process: process)
        }
    }
    
    private func generateProtcolMap(dirs: [String],
                                    exclusionSuffixes: [String]? = nil,
                                    annotation: String,
                                    semaphore: DispatchSemaphore?,
                                    queue: DispatchQueue?,
                                    process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        if let queue = queue {
            let lock = NSLock()
            
            scanPaths(dirs) { filePath in
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    self.generateProtcolMap(filePath,
                                       exclusionSuffixes: exclusionSuffixes,
                                       annotationData: annotationData,
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
                                   annotationData: annotationData,
                                   lock: nil,
                                   process: process)
            }
        }
    }
    
    private func generateProtcolMap(files: [String],
                                    exclusionSuffixes: [String]? = nil,
                                    annotation: String,
                                    semaphore: DispatchSemaphore?,
                                    queue: DispatchQueue?,
                                    process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        
        if let queue = queue {
            let lock = NSLock()
            for filePath in files {
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    self.generateProtcolMap(filePath,
                                       exclusionSuffixes: exclusionSuffixes,
                                       annotationData: annotationData,
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
                                   annotationData: annotationData,
                                   lock: nil,
                                   process: process)
            }
        }
    }
    
    private func generateProtcolMap(_ path: String,
                                    exclusionSuffixes: [String]? = nil,
                                    annotationData: Data,
                                    lock: NSLock?,
                                    process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard path.shouldParse(with: exclusionSuffixes) else { return }
        guard let content = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        
        do {
            var results = [Entity]()
            let topstructure = try Structure(path: path)
            for current in topstructure.substructures {
                if current.isProtocol {
                    let metadata = current.annotationMetadata(with: annotationData, in: content)
                    let isAnnotated = metadata != nil
                    
                    let node = Entity(entityNode: current,
                                      filepath: path,
                                      data: content,
                                      isAnnotated: isAnnotated,
                                      overrides: metadata?.typealiases,
                                      isProcessed: false)
                    results.append(node)
                }
            }
            
            lock?.lock()
            process(results, nil)
            lock?.unlock()
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func generateProcessedModels(_ path: String,
                                         lock: NSLock?,
                                         process: @escaping ([Entity], [String: [String]]) -> ()) {
        
        guard let content = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        
        do {
            let topstructure = try Structure(path: path)
            let subs = topstructure.substructures
            let results = subs.compactMap { current -> Entity? in
                return Entity(entityNode: current,
                              filepath: path,
                              data: content,
                              isAnnotated: false,
                              overrides: nil,
                              isProcessed: true)
            }
            
            let imports = findImportLines(data: content, offset: subs.first?.offset)
            lock?.lock()
            process(results, [path: imports])
            lock?.unlock()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
}


