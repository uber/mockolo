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
    
    var (insideDirectivesImports, normalImports) = importLines.partitioned { $0.insideDirective == nil }

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
    // TODO: Consider nested IfMacroModel
    let insideDirectivesImportsStr = insideDirectivesImports
        .grouped(
            by: \.insideDirective!.directiveId
        )
        .map(\.value)
        .map { imports in
            imports
                .grouped {
                    $0.insideDirective!.clauseType
                }
                .sorted(path: \.key)
                .map { (type, statements) in
                    let imports = String(
                        statements.map(\.line)
                            .filter({ !normalImports.map(\.line).contains($0) })
                            .sorted().joined(by: "\n")
                    )
                    switch type {
                    case .if:
                        let cond = statements.first!.insideDirective!.condition ?? ""
                        return """
                        #if \(cond)
                        \(imports)
                        """
                    case .else:
                        return """
                        #else
                        \(imports)
                        """
                    case .elseif:
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
