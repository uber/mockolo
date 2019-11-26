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
import SwiftSyntax

/// Performs protocol and annotated protocol map generation

func generateProtocolMap(sourceDirs: [String]?,
                         sourceFiles: [String]?,
                         exclusionSuffixes: [String]? = nil,
                         annotation: String,
                         parserType: ParserType,
                         semaphore: DispatchSemaphore?,
                         queue: DispatchQueue?,
                         process: @escaping ([Entity]) -> ()) {
    
    if let sourceDirs = sourceDirs {
        generateProtcolMap(dirs: sourceDirs, exclusionSuffixes: exclusionSuffixes, annotation: annotation, parserType: parserType, semaphore: semaphore, queue: queue, process: process)
    } else if let sourceFiles = sourceFiles {
        generateProtcolMap(files: sourceFiles, exclusionSuffixes: exclusionSuffixes, annotation: annotation, parserType: parserType, semaphore: semaphore, queue: queue, process: process)
    }
}

private func generateProtcolMap(dirs: [String],
                                exclusionSuffixes: [String]? = nil,
                                annotation: String,
                                parserType: ParserType,
                                semaphore: DispatchSemaphore?,
                                queue: DispatchQueue?,
                                process: @escaping ([Entity]) -> ()) {
    
    switch parserType {
    case .sourceKit:
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        if let queue = queue {
            let lock = NSLock()
            
            scanPaths(dirs) { filePath in
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    generateProtcolMap(filePath,
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
    default:
        var treeVisitor = EntityVisitor(annotation: annotation)
        scanPaths(dirs) { filePath in
            generateProtcolMap(filePath,
                               exclusionSuffixes: exclusionSuffixes,
                               annotation: annotation,
                               treeVisitor: &treeVisitor,
                               lock: nil,
                               process: process)
        }
    }
}

private func generateProtcolMap(files: [String],
                                exclusionSuffixes: [String]? = nil,
                                annotation: String,
                                parserType: ParserType,
                                semaphore: DispatchSemaphore?,
                                queue: DispatchQueue?,
                                process: @escaping ([Entity]) -> ()) {
    
    switch parserType {
    case .sourceKit:
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        
        if let queue = queue {
            let lock = NSLock()
            for filePath in files {
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    generateProtcolMap(filePath,
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
    default:
        var treeVisitor = EntityVisitor(annotation: annotation)
        for filePath in files {
            generateProtcolMap(filePath,
                               exclusionSuffixes: exclusionSuffixes,
                               annotation: annotation,
                               treeVisitor: &treeVisitor,
                               lock: nil,
                               process: process)
        }
    }
}


private func generateProtcolMap(_ path: String,
                                exclusionSuffixes: [String]? = nil,
                                annotationData: Data,
                                lock: NSLock?,
                                process: @escaping ([Entity]) -> ()) {
    
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
                let members = current.substructures.compactMap { (child: Structure) -> Model? in
                    return Entity.model(for: child, filepath: path, data: content, overrides: metadata?.typealiases, processed: false)
                }
                
                var attributes = current.substructures.compactMap { (child: Structure) -> [String]? in
                    return child.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
                }.flatMap {$0}
                
                let curAttributes = current.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
                attributes.append(contentsOf: curAttributes)
                
                let hasInit = current.substructures.filter(path: \.isInitializer).count > 0
                
                let node = Entity(name: current.name,
                                  filepath: path,
                                  data: content,
                                  isAnnotated: isAnnotated,
                                  overrides: metadata?.typealiases,
                                  acl: current.accessControlLevelDescription,
                                  attributes: attributes,
                                  inheritedTypes: current.inheritedTypes,
                                  members: members,
                                  hasInit: hasInit,
                                  offset: current.offset,
                                  isProcessed: false)
                results.append(node)
            }
        }
        
        lock?.lock()
        process(results)
        lock?.unlock()
        
    } catch {
        fatalError(error.localizedDescription)
    }
}


private func generateProtcolMap(_ path: String,
                                exclusionSuffixes: [String]? = nil,
                                annotation: String,
                                treeVisitor: inout EntityVisitor,
                                lock: NSLock?,
                                process: @escaping ([Entity]) -> ()) {
    
    guard path.shouldParse(with: exclusionSuffixes) else { return }
    
    do {
        var results = [Entity]()
        let node = try SyntaxParser.parse(path)
        node.walk(&treeVisitor)
        let ret = treeVisitor.entities
        results.append(contentsOf: ret)
        
        lock?.lock()
        process(results)
        lock?.unlock()
        
    } catch {
        fatalError(error.localizedDescription)
    }
}
