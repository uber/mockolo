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

    var imports = [String: [Import]]()
    let defaultKey = ""
    if imports[defaultKey] == nil {
        imports[defaultKey] = []
    }

    for (path, importMap) in pathToImportsMap {
        guard relevantPaths.contains(path) else { continue }
        for (k, v) in importMap {
            if imports[k] == nil {
                imports[k] = []
            }

            if let ex = excludeImports {
                let filtered = v.filter{ !ex.contains($0.moduleNameInImport) }
                imports[k]?.append(contentsOf: filtered.compactMap { Import(line: $0) })
            } else {
                imports[k]?.append(contentsOf: v.compactMap { Import(line: $0) })
            }
        }
    }

    if let customImports = customImports {
        imports[defaultKey]?.append(contentsOf: customImports.compactMap { Import(moduleName: $0) })
    }

    var sortedImports = [String: [Import]]()
    for (k, v) in imports {
        sortedImports[k] = v.resolved()
    }

    if let existingSet = sortedImports[defaultKey] {
        if let testableImportNames = testableImports, !testableImportNames.isEmpty {
            let (passthroughImports, candidateImports) = existingSet.partitioned(by: { testableImportNames.contains($0.moduleName) })
            let mappedImports = candidateImports.map(\.asTestable)
            let newImports: [Import] = testableImportNames.compactMap { name in
                guard !mappedImports.contains(where: { $0.moduleName == name }) else { return nil }
                return Import(moduleName: name, modifier: .testable)
            }
            sortedImports[defaultKey] = (passthroughImports + mappedImports + newImports).resolved()
        }
    }

    let sortedKeys = sortedImports.keys.sorted()
    let importsStr = sortedKeys.map { k in
        let v = sortedImports[k]
        let lines = v?.lines() ?? ""
        if k.isEmpty {
            return lines
        } else {
            return """
            #if \(k)
            \(lines)
            #endif
            """
        }
    }.joined(separator: "\n")

    return importsStr
}
