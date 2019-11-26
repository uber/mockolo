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

/// Performs processed mock type map generation
func generateProcessedTypeMap(_ paths: [String],
                              parserType: ParserType,
                              semaphore: DispatchSemaphore?,
                              queue: DispatchQueue?,
                              process: @escaping ([Entity], [String]) -> ()) {
    
    switch parserType {
    case .sourceKit:
        if let queue = queue {
            let lock = NSLock()
            
            for filePath in paths {
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    generateProcessedModels(filePath, lock: lock, process: process)
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
    default:
        var treeVisitor = EntityVisitor()
        for filePath in paths {
            generateProcessedModels(filePath, treeVisitor: &treeVisitor, lock: nil, process: process)
        }
    }
    
}

private func generateProcessedModels(_ path: String,
                                     lock: NSLock?,
                                     process: @escaping ([Entity], [String]) -> ()) {
    
    guard let content = FileManager.default.contents(atPath: path) else {
        fatalError("Retrieving contents of \(path) failed")
    }
    
    do {
        let topstructure = try Structure(path: path)
        let subs = topstructure.substructures
        let results = subs.compactMap { current -> Entity? in
            let members = current.substructures.compactMap { (child: Structure) -> Model? in
                return Entity.model(for: child, filepath: path, data: content, overrides: nil, processed: true)
            }
            
            let curAttributes = current.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
            let hasInit = current.substructures.filter(path: \.isInitializer).count > 0
            return Entity(name: current.name,
                          filepath: path,
                          data: content,
                          isAnnotated: false,
                          overrides: nil,
                          acl: current.accessControlLevelDescription,
                          attributes: curAttributes,
                          members: members,
                          hasInit: hasInit,
                          offset: current.offset,
                          isProcessed: true)
        }
        
        let imports = findImportLines(data: content, offset: subs.first?.offset)
        lock?.lock()
        process(results, imports)
        lock?.unlock()
    } catch {
        fatalError(error.localizedDescription)
    }
}

private func generateProcessedModels(_ path: String,
                                     treeVisitor: inout EntityVisitor,
                                     lock: NSLock?,
                                     process: @escaping ([Entity], [String]) -> ()) {
    do {
        var results = [Entity]()
        let node = try SyntaxParser.parse(path)
        node.walk(&treeVisitor)
        let ret = treeVisitor.entities
        results.append(contentsOf: ret)
        
        let imports = treeVisitor.imports
        treeVisitor.reset()
        lock?.lock()
        process(results, imports)
        lock?.unlock()
    } catch {
        fatalError(error.localizedDescription)
    }
}
