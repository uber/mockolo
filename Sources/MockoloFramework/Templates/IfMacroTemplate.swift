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

extension IfMacroModel {
    func applyMacroTemplate(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
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
