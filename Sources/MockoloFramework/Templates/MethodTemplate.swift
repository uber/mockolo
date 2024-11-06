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

extension MethodModel {
    func applyMethodTemplate(name: String,
                             kind: MethodKind,
                             arguments: GenerationArguments,
                             isStatic: Bool,
                             customModifiers: [String: Modifier]?,
                             isOverride: Bool,
                             genericTypeParams: [ParamModel],
                             genericWhereClause: String?,
                             params: [ParamModel],
                             returnType: SwiftType,
                             accessLevel: String,
                             argsHistory: ArgumentsHistoryModel?,
                             handler: ClosureModel?,
                             context: RenderContext) -> String {
        guard let overloadingResolvedName = context.overloadingResolvedName else {
            preconditionFailure("context broken")
        }
        var template = ""

        let returnTypeName = returnType.isUnknown ? "" : returnType.typeName

        let acl = accessLevel.isEmpty ? "" : accessLevel+" "
        let genericTypeDeclsStr = genericTypeParams.compactMap {$0.render()}.joined(separator: ", ")
        let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
        let genericWhereStr = genericWhereClause.map { "\($0) " } ?? ""
        let paramDeclsStr = params.compactMap{$0.render()}.joined(separator: ", ")

        switch kind {
        case .initKind(_, _):  // ClassTemplate needs to handle this as it needs a context of all the vars
            return ""
        default:

            guard let handler else { return "" }

            let callCount = "\(overloadingResolvedName)\(String.callCountSuffix)"
            let handlerVarName = "\(overloadingResolvedName)\(String.handlerSuffix)"
            let handlerVarType = handler.type(context: context).typeName // ?? "Any"
            let handlerReturn = handler.render(context: context) ?? ""

            let suffixStr = applyFunctionSuffixTemplate(
                isAsync: isAsync,
                throwing: throwing
            )
            let returnStr = returnTypeName.isEmpty ? "" : "-> \(returnTypeName) "
            let staticStr = isStatic ? String.static + " " : ""
            let keyword = isSubscript ? "" : "func "
            var body = ""

            if arguments.useTemplateFunc {
                let callMockFunc = !throwing.hasError && (handler.type(context: context).cast?.isEmpty ?? false)
                if callMockFunc {
                    let handlerParamValsStr = params.map { (arg) -> String in
                        if arg.type.typeName.hasPrefix(String.autoclosure) {
                            return arg.name.safeName + "()"
                        }
                        return arg.name.safeName
                    }.joined(separator: ", ")

                    let defaultVal = returnType.defaultVal() // ?? "nil"

                    var mockReturn = ".error"
                    if returnType.typeName.isEmpty {
                        mockReturn = ".void"
                    } else if let val = defaultVal {
                        mockReturn = ".val(\(val))"
                    }

                    body = """
                    \(2.tab)mockFunc(&\(callCount))(\"\(name)\", \(handlerVarName)?(\(handlerParamValsStr)), \(mockReturn))
                    """
                }
            }

            if body.isEmpty {
                body = """
                \(2.tab)\(callCount) += 1
                """

                if let argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                    let argsHistoryCapture = argsHistory.render(context: context, arguments: arguments) ?? ""

                    body = """
                    \(body)
                    \(2.tab)\(argsHistoryCapture)
                    """
                }

                body = """
                \(body)
                \(handlerReturn)
                """
            }

            var wrapped = body
            if isSubscript {
                wrapped = """
                \(2.tab)get {
                \(body)
                \(2.tab)}
                \(2.tab)set { }
                """
            }

            let overrideStr = isOverride ? "\(String.override) " : ""
            let modifierTypeStr: String
            if let customModifiers = customModifiers,
            let customModifier: Modifier = customModifiers[name] {
                modifierTypeStr = customModifier.rawValue + " "
            } else {
                modifierTypeStr = ""
            }
            let privateSetSpace = arguments.allowSetCallCount ? "" : "\(String.privateSet) "

            template = """

            \(1.tab)\(acl)\(staticStr)\(privateSetSpace)var \(callCount) = 0
            """

            if let argsHistory = argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                let argsHistoryVarName = "\(overloadingResolvedName)\(String.argsHistorySuffix)"
                let argsHistoryVarType = argsHistory.type.typeName

                template = """
                \(template)
                \(1.tab)\(acl)\(staticStr)var \(argsHistoryVarName) = \(argsHistoryVarType)()
                """
            }

            return """
            \(template)
            \(1.tab)\(acl)\(staticStr)var \(handlerVarName): \(handlerVarType)
            \(1.tab)\(acl)\(staticStr)\(overrideStr)\(modifierTypeStr)\(keyword)\(name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnStr)\(genericWhereStr){
            \(wrapped)
            \(1.tab)}
            """
        }
    }
}
