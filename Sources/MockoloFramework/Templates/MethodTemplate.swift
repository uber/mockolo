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
    func applyMethodTemplate(overloadingResolvedName: String,
                             arguments: GenerationArguments,
                             isOverride: Bool,
                             handler: ClosureModel?,
                             context: RenderContext) -> String {
        if case .initKind = kind {
            return "" // ClassTemplate needs to handle this as it needs a context of all the vars
        }

        guard let handler, let enclosingType = context.enclosingType else { return "" }

        return Renderer(
            model: self,
            context: context,
            arguments: arguments,
            overloadingResolvedName: overloadingResolvedName,
            isOverride: isOverride,
            handler: handler,
            enclosingType: enclosingType
        )
            .render()
    }

    struct Renderer {
        var model: MethodModel
        var context: RenderContext
        var arguments: GenerationArguments
        var overloadingResolvedName: String
        var isOverride: Bool
        var handler: ClosureModel
        var enclosingType: SwiftType

        func render() -> String {
            let body: String
            if arguments.useTemplateFunc
                && !model.throwing.hasError
                && (handler.type(enclosingType: enclosingType).cast?.isEmpty ?? false) {
                let handlerParamValsStr = model.params.map { (arg) -> String in
                    if arg.type.typeName.hasPrefix(String.autoclosure) {
                        return arg.name.safeName + "()"
                    }
                    return arg.name.safeName
                }.joined(separator: ", ")

                let defaultVal = model.returnType.defaultVal() // ?? "nil"

                var mockReturn = ".error"
                if model.returnType.typeName.isEmpty {
                    mockReturn = ".void"
                } else if let val = defaultVal {
                    mockReturn = ".val(\(val))"
                }

                body = """
                \(2.tab)mockFunc(&\(callCountVarName))(\"\(model.name)\", \(handlerVarName)?(\(handlerParamValsStr)), \(mockReturn))
                """
            } else {
                let argsHistoryCaptureCall: String
                if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                    let argsHistoryCapture = argsHistory.render(context: context, arguments: arguments) ?? ""
                    argsHistoryCaptureCall = "\(2.tab)\(argsHistoryCapture)\n"
                } else {
                    argsHistoryCaptureCall = ""
                }

                let handlerReturn = handler.render(context: context, arguments: arguments) ?? ""

                body = """
                \(2.tab)\(callCountVarName) += 1
                \(argsHistoryCaptureCall)\(handlerReturn)
                """
            }

            let wrapped = model.isSubscript ? """
            \(2.tab)get {
            \(body)
            \(2.tab)}
            \(2.tab)set { }
            """ : body

            let overrideStr = isOverride ? String.override.withSpace : ""
            let modifierTypeStr: String
            if let customModifier: Modifier = model.customModifiers[model.name] {
                modifierTypeStr = customModifier.rawValue + " "
            } else {
                modifierTypeStr = ""
            }

            let keyword = model.isSubscript ? "" : "func "
            let genericTypeDeclsStr = model.genericTypeParams.render(context: context, arguments: arguments)
            let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
            let paramDeclsStr = model.params.render(context: context, arguments: arguments)
            let suffixStr = applyFunctionSuffixTemplate(
                isAsync: model.isAsync,
                throwing: model.throwing
            )
            let genericWhereStr = model.genericWhereClause.map { "\($0) " } ?? ""

            let functionDecl = """
            \(1.tab)\(declModifiers)\(overrideStr)\(modifierTypeStr)\(keyword)\(model.name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnClause)\(genericWhereStr){
            \(wrapped)
            \(1.tab)}
            """

            let decls: [String?] = [
                stateVarDecl,
                callCountVarDecl,
                argsHistoryVarDecl,
                handlerVarDecl,
                functionDecl,
            ]
            return "\n" + decls.compactMap { $0 }.joined(separator: "\n")
        }

        var declModifiers: String {
            let acl = model.accessLevel.isEmpty ? "" : model.accessLevel.withSpace
            let staticModifier = model.isStatic ? String.static.withSpace : ""
            return acl + staticModifier
        }

        var returnClause: String {
            let returnTypeName = model.returnType.isUnknown ? "" : model.returnType.typeName
            return returnTypeName.isEmpty ? "" : "-> \(returnTypeName) "
        }

        var handlerVarName: String {
            return overloadingResolvedName + .handlerSuffix
        }

        var stateVarName: String {
            return overloadingResolvedName + .stateSuffix
        }

        var callCountVarName: String {
            return overloadingResolvedName + .callCountSuffix
        }

        var argsHistoryVarName: String {
            return overloadingResolvedName + .argsHistorySuffix
        }

        var stateVarDecl: String? {
            guard context.requiresSendable else { return nil }

            let handlerVarType = handler.type(enclosingType: enclosingType).typeName
            let argumentsTupleType = "TODO"
            return "\(1.tab)private let \(stateVarName) = MockoloMutex(MockoloHandlerState<\(argumentsTupleType), \(handlerVarType)>())"
        }

        var callCountVarDecl: String {
            if !context.requiresSendable {
                let privateSetSpace = arguments.allowSetCallCount ? "" : "\(String.privateSet) "
                return "\(1.tab)\(declModifiers)\(privateSetSpace)var \(callCountVarName) = 0"
            } else {
                if arguments.allowSetCallCount {
                    return """
                    \(1.tab)\(declModifiers)var \(callCountVarName): Int {
                    \(2.tab)get { \(stateVarName).withLock(\\.callCount) }
                    \(2.tab)set { \(stateVarName).withLock { $0.callCount = newValue } }
                    \(1.tab)}
                    """
                } else {
                    return """
                    \(1.tab)\(declModifiers)var \(callCountVarName): Int {
                    \(2.tab)return \(stateVarName).withLock(\\.callCount)
                    \(1.tab)}
                    """
                }
            }
        }

        var argsHistoryVarDecl: String? {
            if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                let argsHistoryVarType = argsHistory.type.typeName

                if !context.requiresSendable {
                    return "\(1.tab)\(declModifiers)var \(argsHistoryVarName) = \(argsHistoryVarType)()"
                } else {
                    return """
                    \(1.tab)\(declModifiers)var \(argsHistoryVarName): \(argsHistoryVarType) {
                    \(2.tab)return \(stateVarName).withLock(\\.argValues).map(\\.value)
                    \(1.tab)}
                    """
                }
            }
            return nil
        }

        var handlerVarDecl: String {
            let handlerVarType = handler.type(enclosingType: enclosingType).typeName // ?? "Any"
            if !context.requiresSendable {
                return "\(1.tab)\(declModifiers)var \(handlerVarName): \(handlerVarType)"
            } else {
                return """
                \(1.tab)\(declModifiers)var \(handlerVarName): \(handlerVarType) {
                \(2.tab)get { \(stateVarName).withLock(\\.handler) }
                \(2.tab)set { \(stateVarName).withLock { $0.handler = newValue } }
                \(1.tab)}
                """
            }
        }
    }
}
