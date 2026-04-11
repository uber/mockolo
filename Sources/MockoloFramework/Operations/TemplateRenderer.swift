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
                     arguments: GenerationArguments,
                     completion: @escaping (String, Int64) -> ()) {
    // Separate standalone entities from #if-grouped entities
    var standalone = [ResolvedEntity]()
    var ifConfigBlockOffsets = Set<Int64>()
    var ifConfigGroups = [Int64: [Int: (IfClauseType, [ResolvedEntity])]]()

    for entity in entities {
        if let context = entity.entity.ifConfigContext {
            ifConfigGroups[context.blockOffset, default: [:]][context.clauseIndex, default: (context.clauseType, [])].1.append(entity)
            ifConfigBlockOffsets.insert(context.blockOffset)
        } else {
            standalone.append(entity)
        }
    }

    // Lock used for thread-safe completion callbacks
    let lock = NSLock()

    // Render standalone entities
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

    // Render #if-grouped entities, preserving #if/#elseif/#else/#endif structure.
    // Note: Only the immediate #if context is preserved. Deeply nested #if blocks
    // (e.g., `#if A #if B protocol P #endif #endif`) will only wrap mocks in the
    // innermost condition.
    for blockOffset in ifConfigBlockOffsets.sorted() {
        guard let clauseMap = ifConfigGroups[blockOffset] else { continue }
        let sortedClauses = clauseMap.sorted(by: { $0.key < $1.key })

        var lines = [String]()
        for (_, (clauseType, clauseEntities)) in sortedClauses {
            switch clauseType {
            case .if(let condition):
                lines.append("#if \(condition)")
            case .elseif(let condition):
                lines.append("#elseif \(condition)")
            case .else:
                lines.append("#else")
            }
            for entity in clauseEntities {
                let mockModel = entity.model()
                if let mockString = mockModel.render(
                    context: .init(),
                    arguments: arguments
                ), !mockString.isEmpty {
                    lines.append(mockString)
                }
            }
        }
        lines.append("#endif")
        completion(lines.joined(separator: "\n"), blockOffset)
    }
}
