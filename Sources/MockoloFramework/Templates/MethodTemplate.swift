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

        private struct AccessorBacking {
            let handlerTypeName: String
            let stateVarName: String
            let callCountVarName: String
            let handlerVarName: String
            let argumentsTupleTypeName: String
        }

        func render() -> String {
            let setter = setterBacking

            let body: String
            if arguments.useTemplateFunc
                && !model.throwing.hasError
                && (handler.type(enclosingType: enclosingType, requiresSendable: context.requiresSendable).cast == nil) {
                let handlerParamValsStr = renderParamValues(includeNewValue: false)

                let defaultVal = model.returnType?.defaultVal()

                var mockReturn = ".error"
                if model.returnType?.isVoid ?? true {
                    mockReturn = ".void"
                } else if let val = defaultVal {
                    mockReturn = ".val(\(val))"
                }

                body = """
                \(2.tab)mockFunc(&\(callCountVarName))(\"\(model.name)\", \(handlerVarName)?(\(handlerParamValsStr)), \(mockReturn))
                """
            } else {
                let handlerReturn = handler.render(context: context, arguments: arguments)

                if requiresConcurrencySafeAccess {
                    let paramNamesStr: String?
                    if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                        paramNamesStr = argsHistory.capturableParamLabels.joined(separator: ", ")
                    } else {
                        paramNamesStr = nil
                    }
                    body = [
                        paramNamesStr.map { "\(2.tab)warnIfNotSendable(\($0))" },
                        "\(2.tab)let \(handlerVarName) = \(stateVarName).withLock { state in",
                        "\(3.tab)state.callCount += 1",
                        paramNamesStr.map { "\(3.tab)state.argValues.append(.init((\($0))))" },
                        "\(3.tab)return state.handler",
                        "\(2.tab)}",
                        handlerReturn,
                    ].compactMap { $0 }.joined(separator: "\n")
                } else {
                    let argsHistoryCaptureCall: String?
                    if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                        let argsHistoryCapture = argsHistory.render(context: context, arguments: arguments) ?? ""
                        argsHistoryCaptureCall = argsHistoryCapture
                    } else {
                        argsHistoryCaptureCall = nil
                    }

                    body = [
                        "\(2.tab)\(callCountVarName) += 1",
                        argsHistoryCaptureCall.map { "\(2.tab)\($0)" },
                        handlerReturn,
                    ].compactMap { $0 }.joined(separator: "\n")
                }
            }

            let wrapped: String
            if model.isSubscript {
                if let setBody = renderSetterBody(setter) {
                    wrapped = """
                    \(2.tab)get {
                    \(body)
                    \(2.tab)}
                    \(2.tab)set {
                    \(setBody)
                    \(2.tab)}
                    """
                } else {
                    wrapped = """
                    \(2.tab)get {
                    \(body)
                    \(2.tab)}
                    """
                }
            } else {
                wrapped = body
            }

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
            
            var availableStr = ""
            var inlineStr = ""
            for attr in model.attributes.components(separatedBy: "\n") where !attr.isEmpty {
                if attr.contains("@available") {
                    availableStr += "\(1.tab)\(attr)\n"
                } else {
                    inlineStr += "\(attr) "
                }
            }

            let functionDecl = """
            \(availableStr)\(1.tab)\(inlineStr)\(declModifiers)\(overrideStr)\(modifierTypeStr)\(keyword)\(model.name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnClause)\(genericWhereStr){
            \(wrapped)
            \(1.tab)}
            """

            let getter = getterBacking
            let decls: [String?] = [
                renderStateVarDecl(getter),
                renderCallCountVarDecl(getter),
                argsHistoryVarDecl,
                renderHandlerVarDecl(getter),
                setter.flatMap { renderStateVarDecl($0) },
                setter.map { renderCallCountVarDecl($0) },
                setter.map { renderHandlerVarDecl($0) },
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
            if let returnType = model.returnType {
                return "-> \(returnType.typeName) "
            } else {
                return ""
            }
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

        /// Returns true if the mock requires concurrency-safe access (via MockoloMutex).
        /// This is true when:
        /// - The protocol inherits Sendable or Error (`requiresSendable`)
        /// - The mock is an actor (needs `nonisolated` computed properties)
        var requiresConcurrencySafeAccess: Bool {
            context.requiresSendable || context.mockDeclKind == .actor
        }

        /// Returns "nonisolated " prefix for actor mocks, empty string otherwise.
        private var nonisolatedSpace: String {
            context.mockDeclKind == .actor ? String.nonisolated.withSpace : ""
        }

        // MARK: - Accessor Backing

        private func handlerTypeName(for closureModel: ClosureModel) -> String {
            closureModel
                .type(enclosingType: enclosingType, requiresSendable: context.requiresSendable)
                .type.typeName
        }

        private var getterBacking: AccessorBacking {
            let argumentsTupleTypeName: String
            if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                argumentsTupleTypeName = argsHistory.capturedValueType.typeName
            } else {
                argumentsTupleTypeName = .neverType
            }
            return AccessorBacking(
                handlerTypeName: handlerTypeName(for: handler),
                stateVarName: stateVarName,
                callCountVarName: callCountVarName,
                handlerVarName: handlerVarName,
                argumentsTupleTypeName: argumentsTupleTypeName
            )
        }

        private var setterBacking: AccessorBacking? {
            guard let setHandler = model.setHandler() else { return nil }
            return AccessorBacking(
                handlerTypeName: handlerTypeName(for: setHandler),
                stateVarName: overloadingResolvedName + .setStateSuffix,
                callCountVarName: overloadingResolvedName + .setCallCountSuffix,
                handlerVarName: overloadingResolvedName + .setHandlerSuffix,
                argumentsTupleTypeName: .neverType
            )
        }

        // MARK: - Shared Rendering Methods

        private func renderStateVarDecl(_ backing: AccessorBacking) -> String? {
            guard requiresConcurrencySafeAccess else { return nil }
            return "\(1.tab)private let \(backing.stateVarName) = MockoloMutex(MockoloHandlerState<\(backing.argumentsTupleTypeName), \(backing.handlerTypeName)>())"
        }

        private func renderCallCountVarDecl(_ backing: AccessorBacking) -> String {
            if !requiresConcurrencySafeAccess {
                let privateSetSpace = arguments.allowSetCallCount ? "" : "\(String.privateSet) "
                return "\(1.tab)\(declModifiers)\(privateSetSpace)var \(backing.callCountVarName) = 0"
            } else {
                if arguments.allowSetCallCount {
                    return """
                    \(1.tab)\(nonisolatedSpace)\(declModifiers)var \(backing.callCountVarName): Int {
                    \(2.tab)get { \(backing.stateVarName).withLock(\\.callCount) }
                    \(2.tab)set { \(backing.stateVarName).withLock { $0.callCount = newValue } }
                    \(1.tab)}
                    """
                } else {
                    return """
                    \(1.tab)\(nonisolatedSpace)\(declModifiers)var \(backing.callCountVarName): Int {
                    \(2.tab)return \(backing.stateVarName).withLock(\\.callCount)
                    \(1.tab)}
                    """
                }
            }
        }

        private func renderHandlerVarDecl(_ backing: AccessorBacking) -> String {
            let handlerVarType = "(\(backing.handlerTypeName))?"
            if !requiresConcurrencySafeAccess {
                return "\(1.tab)\(declModifiers)var \(backing.handlerVarName): \(handlerVarType)"
            } else {
                return """
                \(1.tab)\(nonisolatedSpace)\(declModifiers)var \(backing.handlerVarName): \(handlerVarType) {
                \(2.tab)get { \(backing.stateVarName).withLock(\\.handler) }
                \(2.tab)set { \(backing.stateVarName).withLock { $0.handler = newValue } }
                \(1.tab)}
                """
            }
        }

        // MARK: - Args History (getter-only)

        var argsHistoryVarDecl: String? {
            if let argsHistory = model.argsHistory, argsHistory.enable(force: arguments.enableFuncArgsHistory) {
                let capturedValueType = argsHistory.capturedValueType.typeName

                if !requiresConcurrencySafeAccess {
                    return "\(1.tab)\(declModifiers)var \(argsHistoryVarName) = [\(capturedValueType)]()"
                } else {
                    return """
                    \(1.tab)\(nonisolatedSpace)\(declModifiers)var \(argsHistoryVarName): [\(capturedValueType)] {
                    \(2.tab)return \(stateVarName).withLock(\\.argValues).map(\\.value)
                    \(1.tab)}
                    """
                }
            }
            return nil
        }

        // MARK: - Shared Param Values

        private func renderParamValues(includeNewValue: Bool) -> String {
            let parts = model.params.map { arg -> String in
                if arg.type.typeName.hasPrefix(String.autoclosure) {
                    return arg.name.safeName + "()"
                }
                return arg.name.safeName
            }
            let allParts = includeNewValue ? parts + ["newValue"] : parts
            return allParts.joined(separator: ", ")
        }

        // MARK: - Setter Body

        private func renderSetterBody(_ backing: AccessorBacking?) -> String? {
            guard let backing else { return nil }
            if requiresConcurrencySafeAccess {
                return [
                    "\(2.tab)let \(backing.handlerVarName) = \(backing.stateVarName).withLock { state in",
                    "\(3.tab)state.callCount += 1",
                    "\(3.tab)return state.handler",
                    "\(2.tab)}",
                    "\(2.tab)\(backing.handlerVarName)?(\(renderParamValues(includeNewValue: true)))",
                ].joined(separator: "\n")
            } else {
                return [
                    "\(2.tab)\(backing.callCountVarName) += 1",
                    "\(2.tab)\(backing.handlerVarName)?(\(renderParamValues(includeNewValue: true)))",
                ].joined(separator: "\n")
            }
        }
    }
}
