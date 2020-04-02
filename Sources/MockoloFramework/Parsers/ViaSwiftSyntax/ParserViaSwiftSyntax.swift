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
                                    completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        scan(paths) { (path, lock) in
            self.generateASTs(path, annotation: "", declType: .classType, lock: lock, completion: completion)
        }
    }
    
    public func parseDecls(_ paths: [String]?,
                           isDirs: Bool,
                           exclusionSuffixes: [String]? = nil,
                           annotation: String,
                           declType: DeclType,
                           completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard let paths = paths else { return }
        scan(paths, isDirectory: isDirs) { (path, lock) in
            self.generateASTs(path,
                              exclusionSuffixes: exclusionSuffixes,
                              annotation: annotation,
                              declType: declType,
                              lock: lock,
                              completion: completion)
        }
    }

    private func generateASTs(_ path: String,
                              exclusionSuffixes: [String]? = nil,
                              annotation: String,
                              declType: DeclType,
                              lock: NSLock?,
                              completion: @escaping ([Entity], [String: [String]]?) -> ()) {
        
        guard path.shouldParse(with: exclusionSuffixes) else { return }

        if !annotation.isEmpty {
            if declType == .protocolType, !containsDecl(String.protocolDecl, in: path) {
                return
            }
            if declType == .classType, !containsDecl(String.classDecl, in: path) {
                return
            }
            if declType == .all, !containsDecl(String.protocolDecl, in: path), !containsDecl(String.classDecl, in: path) {
                return
            }
        }

        do {
            var results = [Entity]()
            let node = try SyntaxParser.parse(path)
            var treeVisitor = EntityVisitor(path, annotation: annotation, declType: declType)
            #if swift(>=5.2)
            treeVisitor.walk(node)
            #else
            node.walk(&treeVisitor)
            #endif
            let ret = treeVisitor.entities
            results.append(contentsOf: ret)
            let imports = treeVisitor.imports

            lock?.lock()
            defer {lock?.unlock()}
            completion(results, [path: imports])
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func containsDecl(_ decl: Data?, in path: String) -> Bool {
        guard let decl = decl else { return false }
        guard let content = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        return content.range(of: decl) != nil
    }
}
