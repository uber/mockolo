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

    var topLevelImports: [Import] = []
    var conditionalBlocks: [ConditionalImportBlock] = []

    // 1. Collect imports from all relevant files
    for (path, parsedImports) in pathToImportsMap {
        guard relevantPaths.contains(path) else { continue }

        // Collect top-level imports
        topLevelImports.append(contentsOf: parsedImports.topLevel)

        // Collect conditional blocks
        conditionalBlocks.append(contentsOf: parsedImports.conditional)
    }

    // 2. Apply excludeImports filter to top-level imports
    if let excludes = excludeImports {
        topLevelImports = topLevelImports.filter { !excludes.contains($0.moduleName) }
    }

    // 3. Add custom imports
    if let customImports = customImports {
        topLevelImports.append(contentsOf: customImports.map { Import(moduleName: $0) })
    }

    // 4. Resolve duplicates in top-level imports
    var resolvedTopLevel = topLevelImports.resolved()

    // 5. Apply testableImports modifier
    if let testableImportNames = testableImports, !testableImportNames.isEmpty {
        let (passthroughImports, candidateImports) = resolvedTopLevel.partitioned(by: { testableImportNames.contains($0.moduleName) })
        let mappedImports = candidateImports.map(\.asTestable)
        let newImports: [Import] = testableImportNames.compactMap { name in
            guard !mappedImports.contains(where: { $0.moduleName == name }) else { return nil }
            return Import(moduleName: name, modifier: .testable)
        }
        resolvedTopLevel = (passthroughImports + mappedImports + newImports).resolved()
    }

    // 6. Sort conditional blocks by offset (file appearance order)
    let sortedBlocks = conditionalBlocks.sorted(by: { $0.offset < $1.offset })

    // 7. Generate output
    var lines: [String] = []

    if !resolvedTopLevel.isEmpty {
        lines.append(resolvedTopLevel.lines())
    }

    for block in sortedBlocks {
        lines.append(renderConditionalBlock(block, excludeImports: excludeImports))
    }

    return lines.joined(separator: "\n")
}

/// Recursively renders a ConditionalImportBlock
private func renderConditionalBlock(_ block: ConditionalImportBlock, excludeImports: [String]?) -> String {
    var result = ""

    for (index, clause) in block.clauses.enumerated() {
        // Render directive line
        switch clause.type {
        case .if:
            result += "#if \(clause.condition ?? "")\n"
        case .elseif:
            result += "#elseif \(clause.condition ?? "")\n"
        case .else:
            result += "#else\n"
        }

        // Render contents of this clause
        var clauseLines: [String] = []
        var simpleImports: [Import] = []

        for content in clause.contents {
            switch content {
            case .simple(let imp):
                // Filter excluded imports
                if let excludes = excludeImports, excludes.contains(imp.moduleName) {
                    continue
                }
                simpleImports.append(imp)
            case .conditional(let nestedBlock):
                // First output accumulated simple imports
                if !simpleImports.isEmpty {
                    clauseLines.append(simpleImports.resolved().lines())
                    simpleImports = []
                }
                // Recursively render nested block
                clauseLines.append(renderConditionalBlock(nestedBlock, excludeImports: excludeImports))
            }
        }

        // Output remaining simple imports
        if !simpleImports.isEmpty {
            clauseLines.append(simpleImports.resolved().lines())
        }

        let clauseContent = clauseLines.joined(separator: "\n")
        if !clauseContent.isEmpty {
            result += clauseContent
            if index < block.clauses.count - 1 {
                result += "\n"
            }
        }
    }

    result += "\n#endif"
    return result
}
