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

/// Represents the type of a clause in an #if/#elseif/#else block
public enum ClauseType: Comparable {
    case `if`
    case elseif(order: Int)
    case `else`

    // Comparable implementation: if < elseif(0) < elseif(1) < ... < else
    public static func < (lhs: ClauseType, rhs: ClauseType) -> Bool {
        switch (lhs, rhs) {
        case (.if, .elseif), (.if, .else), (.elseif, .else):
            true
        case (.elseif(let l), .elseif(let r)):
            l < r
        default:
            false
        }
    }
}

final class IfMacroModel: Model {
    /// Represents a single clause in a conditional compilation block
    struct Clause {
        let type: ClauseType
        let condition: String?  // nil for #else
        let entities: [(String, Model)]
    }

    let clauses: [Clause]
    let offset: Int64

    var modelType: ModelType {
        .macro
    }
    
    var name: String {
        clauses.first?.condition ?? ""
    }

    var fullName: String {
        clauses.flatMap(\.entities).map { $0.0 }.joined(separator: "_")
    }

    /// Creates an IfMacroModel with multiple clauses
    init(clauses: [Clause], offset: Int64) {
        self.clauses = clauses
        self.offset = offset
    }

    /// Initializer for simple #if blocks
    convenience init(name: String,
                     offset: Int64,
                     entities: [(String, Model)]) {
        let clause = Clause(type: .if, condition: name, entities: entities)
        self.init(clauses: [clause], offset: offset)
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        applyMacroTemplate(
            context: context,
            arguments: arguments
        )
    }
}
