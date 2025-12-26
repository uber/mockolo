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
enum ClauseType {
    case `if`(_ condition: String)
    case elseif(_ condition: String)
    case `else`

    var condition: String? {
        switch self {
        case .if(let condition), .elseif(let condition):
            return condition
        case .else:
            return nil
        }
    }
}

final class IfMacroModel: Model {
    /// Represents a single clause in a conditional compilation block
    struct Clause {
        var type: ClauseType
        var entities: [(String, Model)]
    }

    let clauses: [Clause]
    let offset: Int64

    var modelType: ModelType {
        .macro
    }
    
    var name: String {
        clauses.first?.type.condition ?? ""
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
        let clause = Clause(type: .if(name), entities: entities)
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
