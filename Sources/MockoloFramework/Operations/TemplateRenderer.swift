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

/// Renders models with templates for output

func renderTemplates(entities: [ResolvedEntity],
                     conditionalBlocks: [ConditionalBlock],
                     arguments: GenerationArguments,
                     completion: @escaping (String, Int64) -> ()) {
    // Build lookup from entity name to resolved entity
    let resolvedByName = Dictionary(
        entities.map { ($0.key, $0) },
        uniquingKeysWith: { $1 }
    )

    // Collect names of entities that live inside conditional blocks
    var conditionalEntityNames = Set<String>()
    func collectEntityNames(from blocks: [ConditionalBlock]) {
        for block in blocks {
            for clause in block.clauses {
                for entity in clause.entities {
                    conditionalEntityNames.insert(entity.entityNode.nameText)
                }
                for content in clause.imports {
                    if case .conditional(let nested) = content {
                        collectEntityNames(from: [nested])
                    }
                }
            }
        }
    }
    collectEntityNames(from: conditionalBlocks)

    // Render conditional blocks, preserving #if/#elseif/#else/#endif structure
    func renderBlock(_ block: ConditionalBlock) -> String? {
        var lines = [String]()
        var blockHasOutput = false

        for clause in block.clauses {
            var clauseLines = [String]()

            // Render entities in this clause
            for entity in clause.entities {
                if let resolved = resolvedByName[entity.entityNode.nameText] {
                    let mockModel = resolved.model()
                    if let mockString = mockModel.render(
                        context: .init(),
                        arguments: arguments
                    ), !mockString.isEmpty {
                        clauseLines.append(mockString)
                    }
                }
            }

            // Recurse into nested conditional blocks
            for content in clause.imports {
                if case .conditional(let nested) = content {
                    if let nestedOutput = renderBlock(nested) {
                        clauseLines.append(nestedOutput)
                    }
                }
            }

            guard !clauseLines.isEmpty else { continue }
            blockHasOutput = true

            switch clause.type {
            case .if(let condition):
                lines.append("#if \(condition)")
            case .elseif(let condition):
                lines.append("#elseif \(condition)")
            case .else:
                lines.append("#else")
            }
            lines.append(contentsOf: clauseLines)
        }

        guard blockHasOutput else { return nil }
        lines.append("#endif")
        return lines.joined(separator: "\n")
    }

    for block in conditionalBlocks {
        if let rendered = renderBlock(block) {
            completion(rendered, block.offset)
        }
    }

    // Render standalone entities (not inside any conditional block)
    let standalone = entities.filter { !conditionalEntityNames.contains($0.key) }

    let lock = NSLock()
    scan(standalone) { (resolvedEntity, _) in
        let mockModel = resolvedEntity.model()
        if let mockString = mockModel.render(
            context: .init(),
            arguments: arguments
        ), !mockString.isEmpty {
            lock.lock()
            completion(mockString, mockModel.offset)
            lock.unlock()
        }
    }
}
