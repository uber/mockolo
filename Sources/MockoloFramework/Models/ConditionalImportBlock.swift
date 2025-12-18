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
    case conditional(ConditionalImportBlock)

    var isConditional: Bool {
        switch self {
        case .simple:
            false
        case .conditional:
            true
        }
    }
}

/// Represents a conditional import block (#if/#elseif/#else/#endif)
struct ConditionalImportBlock {
    /// Represents a single clause in a conditional import block
    struct Clause {
        let type: ClauseType
        let condition: String?  // nil for #else
        var contents: [ImportContent]

        init(type: ClauseType, condition: String?, contents: [ImportContent]) {
            self.type = type
            self.condition = condition
            self.contents = contents
        }
    }

    let clauses: [Clause]
    let offset: Int64

    init(clauses: [Clause], offset: Int64) {
        self.clauses = clauses
        self.offset = offset
    }
}
