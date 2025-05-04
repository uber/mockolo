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
        let condition: String?  // nil == else clause
        let entities: [(String, Model)]
        let clauseType: ClauseType

        enum ClauseType {
            case `if`
            case elseif
            case `else`
        }
    }

    let offset: Int64
    let clauses: [Clause]

    var name: String {
        return clauses.first?.condition ?? ""
    }

    var entities: [(String, Model)] {
        return clauses.first?.entities ?? []
    }

    var modelType: ModelType {
        return .macro
    }

    var fullName: String {
        return clauses.flatMap { $0.entities.map { $0.0 } }.joined(separator: "_")
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
        // Check if there are multiple conditions
        if clauses.count > 1 || (clauses.count == 1 && clauses[0].clauseType != .if) {
            return applyMultiConditionTemplate(context: context, arguments: arguments)
        }

        // there is a single condition
        return applyMacroTemplate(
            name: clauses[0].condition ?? "",
            context: context,
            arguments: arguments,
            entities: clauses[0].entities
        )
    }

    // template for multiple conditions
    private func applyMultiConditionTemplate(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String {
        var result = ""

        for (index, clause) in clauses.enumerated() {
            let rendered = clause.entities
                .compactMap { model in
                    model.1.render(
                        context: .init(
                            overloadingResolvedName: model.0,
                            enclosingType: context.enclosingType,
                            annotatedTypeKind: context.annotatedTypeKind,
                            requiresSendable: context.requiresSendable
                        ),
                        arguments: arguments
                    )
                }
                .joined(separator: "\n")

            switch clause.clauseType {
            case .if:
                result += """
                \(1.tab)#if \(clause.condition!)
                \(rendered)
                """
            case .elseif:
                result += """
                \(1.tab)#elseif \(clause.condition!)
                \(rendered)
                """
            case .else:
                result += """
                \(1.tab)#else
                \(rendered)
                """
            }

            if index < clauses.count - 1 {
                result += "\n"
            }
        }
        
        result += "\n\(1.tab)#endif"
        return result
    }
}
