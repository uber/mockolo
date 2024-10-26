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

extension VariableModel {

    func applyVariableTemplate(name: String,
                               type: SwiftType,
                               encloser: String,
                               isStatic: Bool,
                               customModifiers: [String: Modifier]?,
                               allowSetCallCount: Bool,
                               shouldOverride: Bool,
                               accessLevel: String) -> String {

        let underlyingSetCallCount = "\(name)\(String.setCallCountSuffix)"
        let underlyingVarDefaultVal = type.defaultVal()
        var underlyingType = type.typeName
        if underlyingVarDefaultVal == nil {
            underlyingType = type.underlyingType
        }

        let propertyWrapper = propertyWrapper != nil ? "\(propertyWrapper!) " : ""

        let overrideStr = shouldOverride ? "\(String.override) " : ""
        var acl = accessLevel
        if !acl.isEmpty {
            acl = acl + " "
        }

        var assignVal = ""
        if !shouldOverride, let val = underlyingVarDefaultVal {
            assignVal = "= \(val)"
        }

        let privateSetSpace = allowSetCallCount ? "" :  "\(String.privateSet) "

        let modifierTypeStr: String
        if let customModifiers = self.customModifiers,
           let customModifier: Modifier = customModifiers[name] {
            modifierTypeStr = customModifier.rawValue + " "
        } else {
            modifierTypeStr = ""
        }

        let staticSpace = isStatic ? "\(String.static) " : ""

        switch storageType {
        case .stored(let needSetCount):
            let setCallCountVarDecl = needSetCount ? """
            \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            """ : ""

            var accessorBlockItems: [String] = []
            if needSetCount {
                let didSetBlock = """
                didSet { \(underlyingSetCallCount) += 1 }
                """
                accessorBlockItems.append(didSetBlock)
            }

            let accessorBlock: String
            switch accessorBlockItems.count {
            case 0: accessorBlock = ""
            case 1: accessorBlock = " { \(accessorBlockItems[0]) }"
            default: accessorBlock = """
                 {
                \(accessorBlockItems.map { "\(2.tab)\($0)" }.joined(separator: "\n"))
                \(1.tab)}
                """
            }

            let template: String
            if underlyingVarDefaultVal == nil {
                template = """
                
                \(setCallCountVarDecl)
                \(1.tab)\(propertyWrapper)\(staticSpace)private var \(underlyingName): \(underlyingType) \(assignVal)\(accessorBlock)
                \(1.tab)\(acl)\(staticSpace)\(overrideStr)\(modifierTypeStr)var \(name): \(type.typeName) {
                \(2.tab)get { return \(underlyingName) }
                \(2.tab)set { \(underlyingName) = newValue }
                \(1.tab)}
                """
            } else {
                template = """
                
                \(setCallCountVarDecl)
                \(1.tab)\(propertyWrapper)\(acl)\(staticSpace)\(overrideStr)\(modifierTypeStr)var \(name): \(type.typeName) \(assignVal)\(accessorBlock)
                """
            }

            return template

        case .computed(let effects):
            let body = (ClosureModel(
                name: "",
                genericTypeParams: [],
                paramNames: [],
                paramTypes: [],
                isAsync: effects.isAsync,
                throwing: effects.throwing,
                returnType: type,
                encloser: ""
            ).render(with: name, encloser: "") ?? "")
                .split(separator: "\n")
                .map { "\(1.tab)\($0)" }
                .joined(separator: "\n")

            return """

            \(1.tab)\(acl)\(staticSpace)var \(name)\(String.handlerSuffix): (() \(effects.applyTemplate())-> \(type.typeName))?
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)\(modifierTypeStr)var \(name): \(type.typeName) {
            \(2.tab)get \(effects.applyTemplate()){
            \(body)
            \(2.tab)}
            \(1.tab)}
            """
        }
    }

    func applyCombineVariableTemplate(name: String,
                                      type: SwiftType,
                                      encloser: String,
                                      shouldOverride: Bool,
                                      isStatic: Bool,
                                      accessLevel: String) -> String? {
        let typeName = type.typeName

        guard
            typeName.starts(with: String.anyPublisherLeftAngleBracket),
            let range = typeName.range(of: String.anyPublisherLeftAngleBracket),
            let lastIdx = typeName.lastIndex(of: ">")
        else {
            return nil
        }

        let typeParamStr = typeName[range.upperBound..<lastIdx]
        var subjectTypeStr = ""
        var errorTypeStr = ""
        if let lastCommaIndex = typeParamStr.lastIndex(of: ",") {
            subjectTypeStr = String(typeParamStr[..<lastCommaIndex])
            let nextIndex = typeParamStr.index(after: lastCommaIndex)
            errorTypeStr = String(typeParamStr[nextIndex..<typeParamStr.endIndex]).trimmingCharacters(in: .whitespaces)
        }
        let subjectType = SwiftType(subjectTypeStr)
        let subjectDefaultValue = subjectType.defaultVal()
        let staticSpace = isStatic ? "\(String.static) " : ""
        let acl = accessLevel.isEmpty ? "" : accessLevel + " "
        let thisStr = isStatic ? encloser : "self"
        let overrideStr = shouldOverride ? "\(String.override) " : ""

        switch combineType {
        case .property(_, var wrapperPropertyName):
            // Using a property wrapper to back this publisher, such as @Published

            var template = "\n"
            var isWrapperPropertyOptionalOrForceUnwrapped = false
            if let publishedAliasModel = wrapperAliasModel {
                // If the property required by the protocol/class cannot be optional, the wrapper property will be the underlyingProperty
                // i.e. @Published var _myType: MyType!
                let wrapperPropertyDefaultValue = publishedAliasModel.type.defaultVal()
                if wrapperPropertyDefaultValue == nil {
                    wrapperPropertyName = "_\(wrapperPropertyName)"
                }
                isWrapperPropertyOptionalOrForceUnwrapped = wrapperPropertyDefaultValue == nil || publishedAliasModel.type.isOptional
            }

            var mapping = ""
            if !subjectType.isOptional, isWrapperPropertyOptionalOrForceUnwrapped {
                // If the wrapper property is of type: MyType?/MyType!, but the publisher is of type MyType
                mapping = ".map { $0! }"
            } else if subjectType.isOptional, !isWrapperPropertyOptionalOrForceUnwrapped {
                // If the wrapper property is of type: MyType, but the publisher is of type MyType?
                mapping = ".map { $0 }"
            }

            let setErrorType = ".setFailureType(to: \(errorTypeStr).self)"
            template += """
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) { return \(thisStr).$\(wrapperPropertyName)\(mapping)\(setErrorType).\(String.eraseToAnyPublisher)() }
            """
            return template
        default:
            // Using a combine subject to back this publisher
            var combineSubjectType = combineType ?? .passthroughSubject

            var defaultValue: String? = ""
            if case .currentValueSubject = combineSubjectType {
                defaultValue = subjectDefaultValue
            }

            // Unable to generate default value for this CurrentValueSubject. Default back to PassthroughSubject.
            //
            if defaultValue == nil {
                combineSubjectType = .passthroughSubject
            }
            let underlyingSubjectName = "\(name)\(String.subjectSuffix)"

            let template = """

            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) { return \(thisStr).\(underlyingSubjectName).\(String.eraseToAnyPublisher)() }
            \(1.tab)\(acl)\(staticSpace)\(String.privateSet) var \(underlyingSubjectName) = \(combineSubjectType.typeName)<\(typeParamStr)>(\(defaultValue ?? ""))
            """
            return template
        }
    }

    func applyRxVariableTemplate(name: String,
                                 type: SwiftType,
                                 encloser: String,
                                 rxTypes: [String: String]?,
                                 shouldOverride: Bool,
                                 useMockObservable: Bool,
                                 allowSetCallCount: Bool,
                                 isStatic: Bool,
                                 accessLevel: String) -> String? {

        let staticSpace = isStatic ? "\(String.static) " : ""
        let privateSetSpace = allowSetCallCount ? "" : "\(String.privateSet) "

        if let rxTypes = rxTypes, !rxTypes.isEmpty {
            let (subjectType, _, subjectVal) = type.parseRxVar(overrides: rxTypes, overrideKey: name, isInitParam: true)
            if let underlyingSubjectType = subjectType {

                let underlyingSubjectName = "\(name)\(String.subjectSuffix)"
                let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"

                var defaultValAssignStr = ""
                if let underlyingSubjectTypeDefaultVal = subjectVal {
                    defaultValAssignStr = " = \(underlyingSubjectTypeDefaultVal)"
                } else {
                    defaultValAssignStr = ": \(underlyingSubjectType)!"
                }

                let acl = accessLevel.isEmpty ? "" : accessLevel + " "
                let overrideStr = shouldOverride ? "\(String.override) " : ""


                let setCallCountStmt = "\(underlyingSetCallCount) += 1"
                let fallbackName =  "\(String.underlyingVarPrefix)\(name)"
                var fallbackType = type.typeName
                if type.isIUO || type.isOptional {
                    fallbackType.removeLast()
                }

                let template = """

                \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
                \(1.tab)\(staticSpace)var \(fallbackName): \(fallbackType)? { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(underlyingSubjectName)\(defaultValAssignStr) { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(type.typeName) {
                \(2.tab)get { return \(fallbackName) ?? \(underlyingSubjectName) }
                \(2.tab)set { if let val = newValue as? \(underlyingSubjectType) { \(underlyingSubjectName) = val } else { \(fallbackName) = newValue } }
                \(1.tab)}
                """

                return template
            }
        }

        let typeName = type.typeName
        if let range = typeName.range(of: String.observableLeftAngleBracket), let lastIdx = typeName.lastIndex(of: ">") {
            let typeParamStr = typeName[range.upperBound..<lastIdx]

            let underlyingSubjectName = "\(name)\(String.subjectSuffix)"
            let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"
            let publishSubjectName = underlyingSubjectName
            let publishSubjectType = "\(String.publishSubject)<\(typeParamStr)>"
            let behaviorSubjectName = "\(name)\(String.behaviorSubject)"
            let behaviorSubjectType = "\(String.behaviorSubject)<\(typeParamStr)>"
            let replaySubjectName = "\(name)\(String.replaySubject)"
            let replaySubjectType = "\(String.replaySubject)<\(typeParamStr)>"
            let placeholderVal = "\(String.observableLeftAngleBracket)\(typeParamStr)>.empty()"

            let acl = accessLevel.isEmpty ? "" : accessLevel + " "
            let overrideStr = shouldOverride ? "\(String.override) " : ""
            let thisStr = isStatic ? encloser : "self"

            if useMockObservable {
                var mockObservableInitArgs = ""
                if type.isIUO || type.isOptional {
                    mockObservableInitArgs = "(wrappedValue: \(placeholderVal), unwrapped: \(placeholderVal))"
                } else {
                    mockObservableInitArgs = "(unwrapped: \(placeholderVal))"
                }

                let template = """

                \(1.tab)\(acl)\(staticSpace)var \(underlyingSetCallCount): Int { return \(thisStr)._\(name).callCount }
                \(1.tab)\(acl)\(staticSpace)var \(publishSubjectName): \(publishSubjectType) { return \(thisStr)._\(name).publishSubject }
                \(1.tab)\(acl)\(staticSpace)var \(replaySubjectName): \(replaySubjectType) { return \(thisStr)._\(name).replaySubject }
                \(1.tab)\(acl)\(staticSpace)var \(behaviorSubjectName): \(behaviorSubjectType) { return \(thisStr)._\(name).behaviorSubject }
                \(1.tab)\(String.mockObservable)\(mockObservableInitArgs) \(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName)
                """
                return template
            } else {
                let whichSubject = "\(underlyingSubjectName)Kind"
                let fallbackName = "_\(name)"
                let fallbackType = typeName[typeName.startIndex..<typeName.index(after: lastIdx)]
                let setCallCountStmt = "\(underlyingSetCallCount) += 1"

                let template = """
                \(1.tab)\(staticSpace)private var \(whichSubject) = 0
                \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
                \(1.tab)\(acl)\(staticSpace)var \(publishSubjectName) = \(publishSubjectType)() { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(replaySubjectName) = \(replaySubjectType).create(bufferSize: 1) { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(behaviorSubjectName): \(behaviorSubjectType)! { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(fallbackName): \(fallbackType)! { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) {
                \(2.tab)get {
                \(3.tab)if \(whichSubject) == 0 {
                \(4.tab)return \(publishSubjectName)
                \(3.tab)} else if \(whichSubject) == 1 {
                \(4.tab)return \(behaviorSubjectName)
                \(3.tab)} else if \(whichSubject) == 2 {
                \(4.tab)return \(replaySubjectName)
                \(3.tab)} else {
                \(4.tab)return \(fallbackName)
                \(3.tab)}
                \(2.tab)}
                \(2.tab)set {
                \(3.tab)if let val = newValue as? \(publishSubjectType) {
                \(4.tab)\(publishSubjectName) = val
                \(4.tab)\(whichSubject) = 0
                \(3.tab)} else if let val = newValue as? \(behaviorSubjectType) {
                \(4.tab)\(behaviorSubjectName) = val
                \(4.tab)\(whichSubject) = 1
                \(3.tab)} else if let val = newValue as? \(replaySubjectType) {
                \(4.tab)\(replaySubjectName) = val
                \(4.tab)\(whichSubject) = 2
                \(3.tab)} else {
                \(4.tab)\(fallbackName) = newValue
                \(4.tab)\(whichSubject) = 3
                \(3.tab)}
                \(2.tab)}
                \(1.tab)}
                """
                return template
            }
        }
        return nil
    }
}

extension VariableModel.GetterEffects {
    fileprivate func applyTemplate() -> String {
        var clauses: [String] = []
        if isAsync {
            clauses.append(.async)
        }
        if let throwSyntax = throwing.applyThrowingTemplate() {
            clauses.append(throwSyntax)
        }
        return clauses.map { "\($0) " }.joined()
    }

    fileprivate var callerMarkers: String {
        var clauses: [String] = []
        if throwing.hasError {
            clauses.append(.try)
        }
        if isAsync {
            clauses.append(.await)
        }
        return clauses.map { "\($0) " }.joined()
    }
}
