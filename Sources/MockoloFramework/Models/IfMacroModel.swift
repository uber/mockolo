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

final class IfMacroModel: Model {
    struct Clause {
        /// This value corresponds to `IfConfigDeclSyntax.id`'s hashValue.
        var parentId: Int
        /// This value corresponds to `IfConfigClauseSyntax.id`'s hashValue.
        var id: Int
        var condition: String?  // `nil` means `else` clause
        var entities: [(String, Model)]
        var clauseType: ClauseType

        enum ClauseType: Hashable, Comparable {
            case `if`
            case elseif(order: Int)
            case `else`
            
            init?(order: Int, poundKeyword: String) {
                assert(["#if", "#elseif", "#else"].contains(poundKeyword))
                switch poundKeyword {
                case "#if":
                    self = .if
                case "#elseif":
                    self = .elseif(order: order)
                case "#else":
                    self = .else
                default:
                    return nil
                }
            }
            
            static func > (lhs: ClauseType, rhs: ClauseType) -> Bool {
                switch (lhs, rhs) {
                case (.if, .elseif):
                    false
                case (.if, .else):
                    false
                case (.else, .if):
                    true
                case (.else, .elseif):
                    true
                case (.elseif, .if):
                    true
                case (.elseif, .else):
                    false
                case let (.elseif(lhsOrder), .elseif(rhsOrder)):
                    lhsOrder > rhsOrder
                default:
                    false
                }
            }
            
            static func < (lhs: ClauseType, rhs: ClauseType) -> Bool {
                switch (lhs, rhs) {
                case (.if, .elseif):
                    true
                case (.if, .else):
                    true
                case (.else, .if):
                    false
                case (.else, .elseif):
                    false
                case (.elseif, .if):
                    false
                case (.elseif, .else):
                    true
                case let (.elseif(lhsOrder), .elseif(rhsOrder)):
                    lhsOrder < rhsOrder
                default:
                    false
                }
            }
        }
    }

    let offset: Int64
    let clauses: [Clause]

    var name: String {
        clauses.first?.condition ?? ""
    }

    var entities: [(String, Model)] {
        clauses.first?.entities ?? []
    }

    var modelType: ModelType {
        .macro
    }

    var fullName: String {
        clauses.flatMap { $0.entities.map { $0.0 } }.joined(separator: "_")
    }

    init(clauses: [Clause], offset: Int64) {
        self.clauses = clauses
        self.offset = offset
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
