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
        var condition: String?  // `nil` means `else` clause
        var entities: [(String, Model)]
        var clauseType: ClauseType

        enum ClauseType: Hashable, Comparable {
            case `if`
            case elseif(order: Int)
            case `else`
            
            init?(_ clauseType: String) {
                if clauseType == "if" {
                    self = .if
                } else if clauseType.hasPrefix("elseif-"), let order = Int(String(clauseType.dropFirst(7))) {
                    self = .elseif(order: order)
                } else if clauseType == "else" {
                    self = .else
                } else {
                    return nil
                }
            }
            
            /// order in if-elseif-else block
            ///
            /// `999_999` corresponds to `else` clause
            var order: Int {
                switch self {
                case .if:
                    0
                case .elseif(let order):
                    order
                case .else:
                    999_999
                }
            }
            
            static func > (lhs: ClauseType, rhs: ClauseType) -> Bool {
                lhs.order > rhs.order
            }
            
            static func < (lhs: ClauseType, rhs: ClauseType) -> Bool {
                lhs.order < rhs.order
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

    init(name: String,
         offset: Int64,
         entities: [(String, Model)]) {
        self.offset = offset
        self.clauses = [
            Clause(
                condition: name,
                entities: entities,
                clauseType: .if
            )
        ]
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
