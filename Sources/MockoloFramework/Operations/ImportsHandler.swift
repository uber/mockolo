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

        for `import` in parsedImports {
            switch `import` {
            case .simple(let simple):
                topLevelImports.append(simple)
            case .conditional(let conditional):
                conditionalBlocks.append(conditional)
            }
        }
    }

    // 2. Sort conditional blocks by offset (file appearance order)
    conditionalBlocks.sort(by: { $0.offset < $1.offset })

    // 3. Add custom imports
    if let customImports {
        topLevelImports.append(contentsOf: customImports.map {
            Import(moduleName: $0)
        })
    }

    var contents: [ImportContent] {
        topLevelImports.map { .simple($0) } + conditionalBlocks.map { .conditional($0) }
    }

    // 4. Add testable imports if the import does not exist
    if let testableImports {
        let usedNames = Set(visitModuleName(contents))
        for name in testableImports {
            if !usedNames.contains(name) {
                topLevelImports.append(Import(moduleName: name).asTestable)
            }
        }
    }

    return renderImportContents(
        contents,
        excludeImports: excludeImports,
        testableImports: testableImports
    )
}

private func renderImportContents(
    _ contents: [ImportContent],
    excludeImports: [String]?,
    testableImports: [String]?
) -> String {
    var clauseLines: [String] = []
    var simpleImports: [Import] = []
    func resolveAccumulatedSimpleImports() {
        var work: [Import] = []
        swap(&simpleImports, &work)
        if !work.isEmpty {
            clauseLines.append(work.resolved().lines())
        }
    }

    for content in contents {
        switch content {
        case .simple(var `import`):
            if let excludeImports, excludeImports.contains(`import`.moduleName) {
                continue
            }
            if let testableImports, testableImports.contains(`import`.moduleName) {
                `import` = `import`.asTestable
            }
            simpleImports.append(`import`)
        case .conditional(let block):
            // First output accumulated simple imports
            resolveAccumulatedSimpleImports()

            var result = ""
            for clause in block.clauses {
                switch clause.type {
                case .if(let condition):
                    result += "#if \(condition)\n"
                case .elseif(let condition):
                    result += "#elseif \(condition)\n"
                case .else:
                    result += "#else\n"
                }
                // Recursively render nested block
                result += renderImportContents(clause.contents, excludeImports: excludeImports, testableImports: testableImports)
                result += "\n"
            }
            result += "#endif"
            clauseLines.append(result)
        }
    }
    resolveAccumulatedSimpleImports()

    return clauseLines.joined(separator: "\n")
}

private func visitModuleName(_ contents: [ImportContent]) -> [String] {
    return contents.flatMap { content in
        switch content {
        case .simple(let `import`):
            return [`import`.moduleName]
        case .conditional(let block):
            return visitModuleName(block.clauses.flatMap(\.contents))
        }
    }
}
