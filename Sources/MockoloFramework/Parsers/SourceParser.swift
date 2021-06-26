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


public enum DeclType {
    case protocolType, classType, other, all
}

public class SourceParser {
    public init() {}
    /// Parses processed decls (mock classes) and calls a completion block
    /// @param paths File paths containing processed mocks
    /// @param fileMacro: File level macro
    /// @param completion:The block to be executed on completion
    public func parseProcessedDecls(_ paths: [String],
                                    fileMacro: String?,
                                    completion: @escaping ([Entity], ImportMap?) -> ()) {
        scan(paths) { (path, lock) in
            self.generateASTs(path, annotation: "", fileMacro: fileMacro, declType: .classType, lock: lock, completion: completion)
        }
    }
    /// Parses decls (protocol, class) with annotations (/// @mockable) and calls a completion block
    /// @param paths File/dir paths containing types with mock annotation
    /// @param isDirs:True if paths are dir paths
    /// @param exclusionSuffixess List of file suffixes to exclude when processing
    /// @param annotation The mock annotation
    /// @param fileMacro: File level macro
    /// @param declType: The declaration type, e.g. protocol, class.
    /// @param completion:The block to be executed on completion
    public func parseDecls(_ paths: [String],
                           isDirs: Bool,
                           exclusionSuffixes: [String],
                           annotation: String,
                           fileMacro: String?,
                           declType: DeclType,
                           completion: @escaping ([Entity], ImportMap?) -> ()) {
        
        guard !paths.isEmpty else { return }
        scan(paths, isDirectory: isDirs) { (path, lock) in
            self.generateASTs(path,
                              exclusionSuffixes: exclusionSuffixes,
                              annotation: annotation,
                              fileMacro: fileMacro,
                              declType: declType,
                              lock: lock,
                              completion: completion)
        }
    }

    private func generateASTs(_ path: String,
                              exclusionSuffixes: [String] = [],
                              annotation: String,
                              fileMacro: String?,
                              declType: DeclType,
                              lock: NSLock?,
                              completion: @escaping ([Entity], ImportMap?) -> ()) {
        
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
            let treeVisitor = EntityVisitor(path, annotation: annotation, fileMacro: fileMacro, declType: declType)
            treeVisitor.walk(node)
            let ret = treeVisitor.entities
            results.append(contentsOf: ret)
            let importMap = treeVisitor.imports

            lock?.lock()
            defer {lock?.unlock()}
            completion(results, [path: importMap])
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
