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

import Algorithms
import Foundation

public struct ImportStatement: Hashable {
    
    struct InsideDirective: Hashable {
        var clauseType: IfMacroModel.Clause.ClauseType
        var blockId: String
        var condition: String?
        var key: String {
            "\(condition ?? ""):\(blockId):\(clauseType)"
        }
        var sortedKey: String? {
            clauseType == .if ? (condition ?? "") + blockId : nil
        }
        
        init?(key: String) {
            let parts = key.split(separator: ":").map { String($0) }
            guard let clauseType = IfMacroModel.Clause.ClauseType(parts[2]) else {
                return nil
            }
            self.clauseType = clauseType
            self.blockId = parts[1]
            self.condition = switch clauseType {
                case .if, .elseif:
                parts[0]
            case .else:
                nil
            }
        }
    }
    
    var line: String
    var insideDirective: InsideDirective?
    
    init(line: String, compilerDirectiveKey: String? = nil) {
        self.line = line
        if let compilerDirectiveKey {
            self.insideDirective = .init(key: compilerDirectiveKey)
        }
    }
    
    mutating func makeTestable() {
        line = line.asTestableImport
    }
}

func handleImports(pathToImportsMap: ImportMap,
                   customImports: [String]?,
                   excludeImports: [String]?,
                   testableImports: [String]?,
                   relevantPaths: [String]) -> String {

    var importLines = [ImportStatement]()

    for (path, importStatements) in pathToImportsMap {
        guard relevantPaths.contains(path) else { continue }
        if let ex = excludeImports {
            let filtered = importStatements.filter{ !ex.contains($0.line.moduleNameInImport) }
            importLines.append(contentsOf: filtered)
        } else {
            importLines.append(contentsOf: importStatements)
        }
    }

    if let customImports = customImports {
        importLines.append(
            contentsOf: customImports.map {
                .init(
                    line: $0.asImport
                )
            })
    }
    
    var normalImports = importLines.filter({ $0.insideDirective == nil })
    let insideDirectives: [ImportStatement] = importLines.filter({ $0.insideDirective != nil })

    if !normalImports.isEmpty {
        if let testableImports = testableImports {
            let (nonTestableInList, rawTestableInList) = normalImports.map(\.line).partitioned(by: { testableImports.contains($0.moduleNameInImport) })
            let testableInList = rawTestableInList.map{ "@testable " + $0 }
            let remainingTestable = testableImports.filter { !testableInList.contains($0) }.map {$0.asTestableImport}
            let testable = Set([testableInList, remainingTestable].flatMap{$0}).sorted()
            normalImports = [
                nonTestableInList.sorted(),
                testable
            ].flatMap { $0 }.map {
                .init(line: $0)
            }
        }
    }
    
    let normalImportsStr = normalImports.map(\.line).joined(separator: "\n")
    let insideDirectivesImportsStr = insideDirectives
        .grouped(
            by: \.insideDirective!.blockId
        )
        .sorted(path: \.key)
        .map(\.value)
        .map { imports in
            imports
                .grouped {
                    $0.insideDirective!.clauseType.order
                }
                .sorted(path: \.key)
                .map { (order, statements) in
                    let imports = String(
                        statements.map(\.line)
                            .filter({ !normalImports.map(\.line).contains($0) })
                            .sorted().joined(by: "\n")
                    )
                    switch order {
                    case 0:
                        let cond = statements.first!.insideDirective!.condition ?? ""
                        return """
                        #if \(cond)
                        \(imports)
                        """
                    case 999_999:
                        return """
                        #else
                        \(imports)
                        """
                    default:
                        let cond = statements.first!.insideDirective!.condition ?? ""
                        return """
                        #elseif \(cond)
                        \(imports)
                        """
                    }
                }.joined(separator: "\n") + "\n#endif"
        }.joined(separator: "\n")
    let importsStr = [normalImportsStr, insideDirectivesImportsStr].joined(separator: "\n")
    return importsStr
}
