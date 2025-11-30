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
public indirect enum ImportContent {
    case simple(Import)
    case conditional(ConditionalImportBlock)
}

/// Represents a conditional import block (#if/#elseif/#else/#endif)
public struct ConditionalImportBlock {
    /// Represents a single clause in a conditional import block
    public struct Clause {
        public let type: ClauseType
        public let condition: String?  // nil for #else
        public var contents: [ImportContent]

        public init(type: ClauseType, condition: String?, contents: [ImportContent]) {
            self.type = type
            self.condition = condition
            self.contents = contents
        }
    }

    public let clauses: [Clause]
    public let offset: Int64

    public init(clauses: [Clause], offset: Int64) {
        self.clauses = clauses
        self.offset = offset
    }
}
