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

/// Represents import content: either a simple import statement or a nested conditional block
indirect enum ImportContent {
    case simple(Import)
    case conditional(ConditionalBlock)
}

/// Represents a conditional compilation block (#if/#elseif/#else/#endif) that owns
/// both imports and entities found within its clauses.
struct ConditionalBlock {
    /// Represents a single clause in a conditional compilation block
    struct Clause {
        var type: IfClauseType
        var imports: [ImportContent]
        var entities: [Entity]
    }

    let clauses: [Clause]
    let offset: Int64

    /// Whether any clause (including nested blocks) contains entities
    var containsEntities: Bool {
        clauses.contains { clause in
            !clause.entities.isEmpty || clause.imports.contains { content in
                if case .conditional(let nested) = content {
                    return nested.containsEntities
                }
                return false
            }
        }
    }

    init(clauses: [Clause], offset: Int64) {
        self.clauses = clauses
        self.offset = offset
    }
}
