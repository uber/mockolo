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
    
    public func parseProcessedDecls(_ paths: [String],
                                    semaphore: DispatchSemaphore?,
                                    queue: DispatchQueue?,
                                    completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        var treeVisitor = EntityVisitor()
        for filePath in paths {
            generateASTs(filePath, annotation: "", treeVisitor: &treeVisitor, completion: completion)
        }
    }
    
    public func parseDecls(_ paths: [String]?,
                           isDirs: Bool,
                           exclusionSuffixes: [String]? = nil,
                           annotation: String,
                           semaphore: DispatchSemaphore?,
                           queue: DispatchQueue?,
                           completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let paths = paths else { return }
        
        var treeVisitor = EntityVisitor(annotation: annotation)
        
        if isDirs {
            scanPaths(paths) { filePath in
                generateASTs(filePath,
                             exclusionSuffixes: exclusionSuffixes,
                             annotation: annotation,
                             treeVisitor: &treeVisitor,
                             completion: completion)
            }
        } else {
            for filePath in paths {
                generateASTs(filePath, exclusionSuffixes: exclusionSuffixes, annotation: annotation, treeVisitor: &treeVisitor, completion: completion)
            }
            
        }
    }
    
    private func generateASTs(_ path: String,
                              exclusionSuffixes: [String]? = nil,
                              annotation: String,
                              treeVisitor: inout EntityVisitor,
                              completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        
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
            
            completion(results, [path: imports])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
