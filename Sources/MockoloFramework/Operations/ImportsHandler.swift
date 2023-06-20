//
//  ImportsHandler.swift
//  MockoloFramework
//
//  Created by Ellie on 4/8/20.
//

import Foundation

func handleImports(pathToImportsMap: ImportMap,
                   pathToContentMap: [(String, Data, Int64)],
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

    for (_, filecontent, offset) in pathToContentMap {
        let v = filecontent.findImportLines(at: offset)
        if let ex = excludeImports {
            let filtered = v.filter{ !ex.contains($0.moduleNameInImport) }
            importLines[defaultKey]?.append(contentsOf: filtered)
        } else {
            importLines[defaultKey]?.append(contentsOf: v)
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
            let nonTestableInList = existingSet.filter { !testableImports.contains($0.moduleNameInImport) }.map{$0}
            let testableInList = existingSet.filter { testableImports.contains($0.moduleNameInImport) }.map{ "@testable " + $0 }
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
