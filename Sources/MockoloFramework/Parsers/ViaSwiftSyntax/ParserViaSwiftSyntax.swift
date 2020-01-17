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
import SwiftSyntax

public class ParserViaSwiftSyntax: SourceParsing {

    public init() {}

    /// Performs processed mock type map generation
    public func parseClasses(_ paths: [String],
                             semaphore: DispatchSemaphore?,
                             queue: DispatchQueue?,
                             process: @escaping ([Entity], [String: [String]]) -> ()) {
        var treeVisitor = EntityVisitor(entityType: .classType)
        for filePath in paths {
            generateProcessedModels(filePath, treeVisitor: &treeVisitor, lock: nil, process: process)
        }
    }
    
    public func parseProtocols(_ paths: [String]?,
                               isDirs: Bool,
                               exclusionSuffixes: [String]? = nil,
                               annotation: String,
                               semaphore: DispatchSemaphore?,
                               queue: DispatchQueue?,
                               process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let paths = paths else { return }
        
        var treeVisitor = EntityVisitor(annotation: annotation, entityType: .protocolType)
        
        if isDirs {
            scanPaths(paths) { filePath in
                generateProtcolMap(filePath,
                                   exclusionSuffixes: exclusionSuffixes,
                                   annotation: annotation,
                                   treeVisitor: &treeVisitor,
                                   lock: nil,
                                   process: process)
            }
        } else {
            for filePath in paths {
                generateProtcolMap(filePath, exclusionSuffixes: exclusionSuffixes, annotation: annotation, treeVisitor: &treeVisitor, lock: nil, process: process)
            }
            
        }
    }
    
    private func generateProtcolMap(_ path: String,
                                    exclusionSuffixes: [String]? = nil,
                                    annotation: String,
                                    treeVisitor: inout EntityVisitor,
                                    lock: NSLock?,
                                    process: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard path.shouldParse(with: exclusionSuffixes) else { return }
        do {
            var results = [Entity]()
            let node = try SyntaxParser.parse(path)
            node.walk(&treeVisitor)
            let ret = treeVisitor.entities
            for ent in ret {
                ent.filepath = path
            }
            results.append(contentsOf: ret)
            let imports = treeVisitor.imports
            treeVisitor.reset()
            
            lock?.lock()
            process(results, [path: imports])
            lock?.unlock()
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    private func generateProcessedModels(_ path: String,
                                         treeVisitor: inout EntityVisitor,
                                         lock: NSLock?,
                                         process: @escaping ([Entity], [String: [String]]) -> ()) {
        
        do {
            var results = [Entity]()
            let node = try SyntaxParser.parse(path)
            node.walk(&treeVisitor)
            let ret = treeVisitor.entities
            for ent in ret {
                ent.filepath = path
            }
            results.append(contentsOf: ret)
            let imports = treeVisitor.imports
            treeVisitor.reset()
            
            lock?.lock()
            process(results, [path: imports])
            lock?.unlock()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
