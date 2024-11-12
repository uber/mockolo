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
    let importsStr = sortedKeys.map { k in
        let v = sortedImports[k]
        let lines = v?.joined(separator: "\n") ?? ""
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
