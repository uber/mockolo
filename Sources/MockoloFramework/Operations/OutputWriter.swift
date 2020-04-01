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

/// Combines a list of entities and import lines and header and writes the final output
func write(candidates: [(String, Int64)],
           pathToImportsMap: [String: [String]],
           relevantPaths: [String],
           pathToContentMap: [(String, Data, Int64)],
           header: String?,
           macro: String?,
           testableImports: [String]?,
           customImports: [String]?,
           to outputFilePath: String) -> String {
    
    var importLines = [String]()
    for path in relevantPaths {
        if let lines = pathToImportsMap[path] {
            importLines.append(contentsOf: lines)
        }
    }
    for (_, filecontent, offset) in pathToContentMap {
        let v = findImportLines(data: filecontent, offset: offset)
        importLines.append(contentsOf: v)
        break
    }
    
    if let customImports = customImports {
        importLines.append(contentsOf: customImports.map {$0.asImport})
    }
    
    var importLineStr = ""
    
    if let testableImports = testableImports {
        var imports = importLines.compactMap { (importLine) -> String? in
            return importLine.moduleName
        }
        imports.append(contentsOf: testableImports)
        importLineStr = Set(imports)
            .sorted()
            .map { testableModuleName -> String in
            guard testableImports.contains(testableModuleName) else {
                return testableModuleName.asImport
            }
            return testableModuleName.asTestableImport
        }
        .joined(separator: "\n")
    } else {
        let importsSet = Set(importLines.map{$0.trimmingCharacters(in: .whitespaces)})
        importLineStr = importsSet.sorted().joined(separator: "\n")
    }

    let entities = candidates
        .sorted { (left: (String, Int64), right: (String, Int64)) -> Bool in
            if left.1 == right.1 {
                return left.0 < right.0
            }
            return left.1 < right.1
        }
        .map{$0.0}
    
    let headerStr = (header ?? "") + .headerDoc
    var macroStart = ""
    var macroEnd = ""
    if let mcr = macro, !mcr.isEmpty {
        macroStart = .poundIf + mcr
        macroEnd = .poundEndIf
    }
    let ret = [headerStr, macroStart, importLineStr, entities.joined(separator: "\n"), macroEnd].joined(separator: "\n\n")
    
    _ = try? ret.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    return ret
}

