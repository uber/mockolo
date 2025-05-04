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

func handleImports(pathToImportsMap: ImportMap,
                   customImports: [String]?,
                   excludeImports: [String]?,
                   testableImports: [String]?,
                   relevantPaths: [String]) -> String {

    var importLines = [String: [String]]()
    let defaultKey = ""
    if importLines[defaultKey] == nil {
        importLines[defaultKey] = []
    }

    for (path, importMap) in pathToImportsMap {
        guard relevantPaths.contains(path) else { continue }
        for (k, v) in importMap {
            if importLines[k] == nil {
                importLines[k] = []
            }

            if let ex = excludeImports {
                let filtered = v.filter{ !ex.contains($0.moduleNameInImport) }
                importLines[k]?.append(contentsOf: filtered)
            } else {
                importLines[k]?.append(contentsOf: v)
            }
        }
    }

    if let customImports = customImports {
        importLines[defaultKey]?.append(contentsOf: customImports.map {$0.asImport})
    }

    var sortedImports = [String: [String]]()
    for (k, v) in importLines {
        sortedImports[k] = Set(v).sorted()
    }

    if let existingSet = sortedImports[defaultKey] {
        if let testableImports = testableImports {
            let (nonTestableInList, rawTestableInList) = existingSet.partitioned(by: { testableImports.contains($0.moduleNameInImport) })
            let testableInList = rawTestableInList.map{ "@testable " + $0 }
            let remainingTestable = testableImports.filter { !testableInList.contains($0) }.map {$0.asTestableImport}
            let testable = Set([testableInList, remainingTestable].flatMap{$0}).sorted()
            sortedImports[defaultKey] = [nonTestableInList, testable].flatMap{$0}
        }
    }

    let sortedKeys = sortedImports.keys.sorted()
    var blockImports: [String: [(type: IfMacroModel.Clause.ClauseType, condition: String, imports: [String])]] = [:]

    for k in sortedKeys {
        if k.hasPrefix("elseif:") {
            let parts = k.split(separator: ":")
            assert(parts.count >= 3, "Invalid elseif key format")
            if parts.count >= 3 {
                let blockId = String(parts[1])
                let condition = String(parts[2...].joined(separator: ":"))

                if blockImports[blockId] == nil {
                    blockImports[blockId] = []
                }

                blockImports[blockId]!.append(
                    (
                        type: .elseif,
                        condition: condition,
                        imports: sortedImports[k] ?? []
                    )
                )
            }
        } else if k.hasPrefix("else:") {
            let parts = k.split(separator: ":")
            assert(parts.count >= 2, "Invalid else key format")
            if parts.count >= 2 {
                let blockId = String(parts[1])
                let condition = String(parts[2...].joined(separator: ":"))

                if blockImports[blockId] == nil {
                    blockImports[blockId] = []
                }

                blockImports[blockId]!.append(
                        (
                            type: .else,
                            condition: condition,
                            imports: sortedImports[k] ?? []
                        )
                    )
            }
        }
    }

    var processedKeys = Set<String>()
    let importsStr = sortedKeys.compactMap { k -> String? in
        if processedKeys.contains(k) {
            return nil
        }

        let v = sortedImports[k]
        let lines = v?.joined(separator: "\n") ?? ""
        if k.isEmpty {
            return lines
        } else if k.hasPrefix("elseif:") || k.hasPrefix("else:") {
            // Processed in the blockImports section.
            processedKeys.insert(k)
            return nil
        } else {
            // Process blockImports.
            let elseifEntries = blockImports.values.flatMap { $0 }.filter { $0.imports.count > 0 }

            if !elseifEntries.isEmpty {
                var result = """
                #if \(k)
                \(lines)
                
                """
                let poundElseIfEntries = elseifEntries.filter { $0.type == .elseif }
                let poundElseEntries = elseifEntries.filter { $0.type == .else }
                for entry in poundElseIfEntries {
                    result += """
                    #elseif \(entry.condition)
                    \(entry.imports.joined(separator: "\n"))
                    
                    """
                    processedKeys.insert("elseif:\(entry.condition)")
                }
                for entry in poundElseEntries {
                    result += """
                    #else
                    \(entry.imports.joined(separator: "\n"))
                    
                    """
                    processedKeys.insert("else:")
                }
                result += "#endif"
                return result
            } else {
                return """
                #if \(k)
                \(lines)
                #endif
                """
            }
        }
    }.joined(separator: "\n")

    return importsStr
}
