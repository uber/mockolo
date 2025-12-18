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

extension IfMacroModel {

    func applyMacroTemplate(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String {
        var lines = [String]()

        for clause in clauses {
            // Render the directive line
            let directive: String
            switch clause.type {
            case .if:
                directive = "\(1.tab)#if \(clause.condition ?? "")"
            case .elseif:
                directive = "\(1.tab)#elseif \(clause.condition ?? "")"
            case .else:
                directive = "\(1.tab)#else"
            }
            lines.append(directive)

            // Render entities in this clause
            let rendered = clause.entities
                .compactMap { model in
                    model.1.render(
                        context: .init(
                            overloadingResolvedName: model.0,
                            enclosingType: context.enclosingType,
                            annotatedTypeKind: context.annotatedTypeKind
                        ),
                        arguments: arguments
                    )
                }
                .joined(separator: "\n")

            if !rendered.isEmpty {
                lines.append(rendered)
            }
        }

        lines.append("\(1.tab)#endif")
        return lines.joined(separator: "\n")
    }
}
