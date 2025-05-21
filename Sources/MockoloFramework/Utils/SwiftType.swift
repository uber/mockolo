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

import SwiftSyntax

typealias SwiftType = SwiftTypeNew

struct SwiftTypeNew: Equatable, CustomStringConvertible {
    enum Kind: Equatable {
        case tuple(Tuple)
        case nominal(Nominal)
        case closure(Closure)
        case composition(Composition)
    }

    struct Tuple: Equatable {
        struct Element: Equatable {
            var label: String?
            var type: SwiftTypeNew
        }
        var elements: [Element]
    }

    struct Nominal: Equatable {
        var name: String
        var genericParameterTypes: [SwiftTypeNew] = []
    }

    struct Closure: Equatable {
        var isAsync: Bool
        var throwing: ThrowingKind
        struct Argument: Equatable {
            var firstName: String?
            var secondName: String?
            var type: SwiftTypeNew
        }
        var arguments: [Argument]
        @CoW var returning: SwiftTypeNew
    }

    struct Composition: Equatable {
        var elements: [SwiftTypeNew]
    }

    var kind: Kind
    var attributes: [String] = []
    var someOrAny: SomeOrAny?
    var isIUO: Bool = false
    var hasEllipsis: Bool = false

    var typeName: String {
        description
    }

    var description: String {
        var repr: String
        repr = "\(attributes.map({ "\($0) " }).joined())"
        if let someOrAny {
            repr += "\(someOrAny.rawValue) "
        }
        switch kind {
        case .tuple(let tuple):
            let elements = tuple.elements.map { e in
                if let label = e.label {
                    return "\(label): \(e.type)"
                }
                return e.type.description
            }
            repr += "(\(elements.joined(separator: ", ")))"
        case .nominal(let nominal):
            switch nominal.name {
            case .optionalTypeSugarName where nominal.genericParameterTypes.count == 1:
                repr += "\(nominal.genericParameterTypes[0])?"
            case .arrayTypeSugarName where nominal.genericParameterTypes.count == 1:
                repr += "[\(nominal.genericParameterTypes[0])]"
            case .dictionaryTypeSugarName where nominal.genericParameterTypes.count == 2:
                repr += "[\(nominal.genericParameterTypes[0]): \(nominal.genericParameterTypes[1])]"
            default:
                repr += nominal.name
                if !nominal.genericParameterTypes.isEmpty {
                    let parameterTypes = nominal.genericParameterTypes.map(\.description)
                    repr += "<\(parameterTypes.joined(separator: ", "))>"
                }
            }
        case .closure(let closure):
            let params = closure.arguments.map {
                let labels = [$0.firstName, $0.secondName].compactMap { $0 }
                if labels.isEmpty {
                    return $0.type.description
                } else {
                    return "\(labels.joined(separator: " ")): \($0.type)"
                }
            }.joined(separator: ", ")

            var closureDesc = "(\(params))"
            if closure.isAsync {
                closureDesc += " async"
            }
            if let throwing = closure.throwing.applyThrowingTemplate() {
                closureDesc += " \(throwing)"
            }
            closureDesc += " -> \(closure.returning.description)"
            repr += closureDesc
        case .composition(let composition):
            repr += composition.elements.map(\.description).joined(separator: " & ")
        }
        if isIUO {
            switch kind {
            case .tuple, .nominal:
                repr += "!"
            case .closure, .composition:
                repr = "(\(repr))!"
            }
        }
        if hasEllipsis {
            repr += "..."
        }
        return repr
    }

    /// variable safe name
    var displayName: String {
        return typeName.displayableComponents.map(\.capitalizeFirstLetter).joined()
    }

    func includingIdentifiers() -> [String] {
        switch kind {
        case .tuple(let tuple):
            return tuple.elements.flatMap { $0.type.includingIdentifiers() }
        case .nominal(let nominal):
            return CollectionOfOne(nominal.name) + nominal.genericParameterTypes.flatMap { $0.includingIdentifiers() }
        case .closure(let closure):
            return closure.arguments.flatMap { $0.type.includingIdentifiers() } + closure.returning.includingIdentifiers()
        case .composition(let composition):
            return composition.elements.flatMap { $0.includingIdentifiers() }
        }
    }

    var isOptional: Bool {
        isNominal(named: .optional) || isNominal(named: .optionalTypeSugarName)
    }

    var isSelf: Bool {
        isNominal(named: .Self)
    }

    var isVoid: Bool {
        if case .tuple(let tuple) = kind {
            return tuple.elements.isEmpty
        } else {
            return isNominal(named: "Void")
        }
    }

    var isClosure: Bool {
        switch kind {
        case .tuple(let tuple):
            if tuple.elements.count == 1 {
                return tuple.elements[0].type.isClosure
            }
            return false
        case .nominal(let nominal):
            if nominal.genericParameterTypes.count == 1
                && (nominal.name == .optional || nominal.name == .optionalTypeSugarName) {
                return nominal.genericParameterTypes[0].isClosure
            }
            // Could be a closure with typealias, but it cannot detect.
            return attributes.contains(.escaping)
        case .closure:
            return true
        case .composition:
            return false
        }
    }

    var isEscapable: Bool {
        switch kind {
        case .tuple(let tuple):
            if tuple.elements.count == 1 {
                return tuple.elements[0].type.isEscapable
            }
            return true
        case .nominal:
            // Could be a non-escaping closure with typealias, but it cannot detect.
            return true
        case .closure:
            return attributes.contains(.escaping)
        case .composition:
            return true
        }
    }

    func isNominal(named: String) -> Bool {
        if case .nominal(let nominal) = kind {
            return nominal.name == named
        } else {
            return false
        }
    }

    var isInOut: Bool {
        attributes.contains(.inout)
    }

    var isEscaping: Bool {
        attributes.contains(where: { $0 == .escaping })
    }

    var isAutoclosure: Bool {
        attributes.contains(where: { $0 == .autoclosure })
    }

    var underlyingType: String {
        var ret = self

        // If @escaping, remove as it can only be used for a func parameter.
        ret.attributes.removeAll(where: { $0 == .escaping })

        let isNominal = if case .nominal = kind { true } else { false }

        // Use force unwrapped for the underlying type so it doesn't always have to be set in the init (need to allow blank init).
        if isClosure && !isNominal {
            ret = ret.copy(
                kind: .tuple(.init(elements: [.init(type: .init(kind: ret.kind))]))
            )
        } else if someOrAny == .any {
            ret = .init(kind: .tuple(
                .init(elements: [.init(type: ret)])
            ))
        } else {
            if let unwrapped = ret.optionalUnwrapped() {
                ret = unwrapped
            }
        }
        ret.isIUO = true

        return ret.description
    }

    func defaultVal(with overrides: [String: String]? = nil, overrideKey: String = "", isInitParam: Bool = false) -> String? {
        if let (_, typeParam, subjectVal) = parseRxVar(overrides: overrides, overrideKey: overrideKey, isInitParam: isInitParam) {
            if isInitParam {
                return subjectVal
            }
            let prefix = typeName.hasPrefix(String.rxObservableLeftAngleBracket) ? String.rxObservableLeftAngleBracket : String.observableLeftAngleBracket
            return "\(prefix)\(typeParam)>.empty()"
        }

        func parseDefaultVal(type: SwiftType, isInitParam: Bool) -> String? {
            if let val = defaultSingularVal(isInitParam: isInitParam) {
                return val
            }

            switch type.kind {
            case .tuple(let tuple):
                var defaultValues: [String] = []
                for element in tuple.elements {
                    guard let value = parseDefaultVal(type: element.type, isInitParam: isInitParam) else {
                        return nil
                    }
                    defaultValues.append(value)
                }
                return "(\(defaultValues.joined(separator: ", ")))"
            case .nominal:
                return type.defaultSingularVal(isInitParam: isInitParam)
            case .closure, .composition:
                return nil
            }
        }

        if let val = parseDefaultVal(type: self, isInitParam: isInitParam) {
            return val
        }

        if case .nominal(let nominal) = kind {
            if let val = SwiftTypeOld.customDefaultValueMap?[nominal.name] {
                return val
            }
        }

        return nil
    }

    static func toArgumentsCaptureType(with params: [(label: String, type: SwiftTypeNew)], typeParams: [String]) -> SwiftTypeNew {
        assert(!params.isEmpty)

        // Expected only history capturable types.
        let displayableParamTypes = params.map { $0.type }.compactMap { (subtype: SwiftTypeNew) -> SwiftTypeNew? in
            var processedType = subtype.processTypeParams(with: typeParams)
            processedType.attributes.removeAll(where: { $0 == .inout })
            processedType.attributes.removeAll(where: { $0 == .escaping })
            processedType.isIUO = false
            return processedType
        }

        if displayableParamTypes.count >= 2 {
            let elements = zip(params.map(\.label), displayableParamTypes).map {
                Tuple.Element(label: $0, type: $1)
            }
            return .init(kind: .tuple(.init(
                elements: elements
            )))
        } else {
            return displayableParamTypes[0]
        }
    }

    func processTypeParams(with typeParamList: [String]) -> SwiftTypeNew {
        if someOrAny == .some {
            var result = self
            result.someOrAny = .any
            return result
        }

        switch kind {
        case .tuple(let tuple):
            let newElements = tuple.elements.map {
                Tuple.Element(label: $0.label, type: $0.type.processTypeParams(with: typeParamList))
            }

            /// convert `(Any)` to `Any` for readability
            if newElements.count == 1 && newElements[0].type == .Any {
                return newElements[0].type
            }

            return self.copy(kind: .tuple(.init(elements: newElements)))
        case .nominal(let nominal):
            if isOptional {
                let wrapped = nominal.genericParameterTypes[0].processTypeParams(with: typeParamList)
                var resultKind = nominal
                resultKind.genericParameterTypes[0] = wrapped
                return self.copy(kind: .nominal(resultKind))
            }

            let typeIDs = includingIdentifiers()
            let hasGenericType = typeParamList.contains(where: { typeIDs.contains($0) })
            if hasGenericType {
                var result = self
                result.kind = SwiftType.Any.kind
                result.someOrAny = nil
                return result
            } else {
                return self
            }
        case .closure(var closure):
            if closure.arguments.contains(where: {
                $0.type.processTypeParams(with: typeParamList) != $0.type
            }) {
                return .Any
            }
            closure.returning = closure.returning.processTypeParams(with: typeParamList)
            return self.copy(kind: .closure(closure))
        case .composition(let composition):
            return self.copy(kind: .composition(.init(
                elements: composition.elements.map { $0.processTypeParams(with: typeParamList) }
            )))
        }
    }

    private func defaultSingularVal(isInitParam: Bool = false, overrides: [String: String]? = nil, overrideKey: String = "") -> String? {
        let arg = self

        if arg.isOptional {
            return "nil"
        }

        if case .nominal(let nominal) = kind, !nominal.genericParameterTypes.isEmpty {
            if SwiftTypeOld.bracketPrefixTypes.contains(nominal.name) {
                return "\(arg)()"
            } else if let val = SwiftTypeOld.rxTypes[nominal.name], let suffix = val {
                return "\(arg)\(suffix)"
            } else {
                return nil
            }
        }

        if let val = SwiftTypeOld.defaultValueMap[arg.description] {
            return val
        }
        return nil
    }

    static func toClosureType(
        params: [SwiftType],
        typeParams: [String],
        isAsync: Bool,
        throwing: ThrowingKind,
        returnType: SwiftType,
        encloser: SwiftType,
        requiresSendable: Bool
    ) -> (type: SwiftType, cast: String?) {
        var displayableReturnType = returnType
        var returnTypeCast: String?

        let returnComps = displayableReturnType.includingIdentifiers()
        if typeParams.contains(where: { returnComps.contains($0)}) {
            var asSuffix = "!"
            let returnAsType: SwiftType

            if let unwrapped = returnType.optionalUnwrapped() {
                displayableReturnType = .Any.optionalWrapped()
                returnAsType = unwrapped
                asSuffix = "?"
            } else if returnType.isIUO {
                displayableReturnType = .Any
                displayableReturnType.isIUO = true
                var asType = returnType
                asType.isIUO = false
                returnAsType = asType
            } else if returnType.isSelf {
                returnAsType = .Self
            } else {
                returnAsType = returnType
                displayableReturnType = .Any
            }

            returnTypeCast = " as\(asSuffix) \(returnAsType)"
        }

        if returnType.isSelf {
            displayableReturnType = encloser
            returnTypeCast = " as! " + .`Self`
        }

//        if !(Self(displayableReturnType).isSingular || Self(displayableReturnType).isOptional) {
//            displayableReturnType = "(\(displayableReturnType))"
//        }

        var resultType = SwiftType(
            kind: .closure(.init(
                isAsync: isAsync,
                throwing: throwing,
                arguments: params.map { .init(type: $0.processTypeParams(with: typeParams)) },
                returning: displayableReturnType
            ))
        )
        if requiresSendable {
            resultType.attributes.append("@Sendable")
        }
        return (type: resultType, cast: returnTypeCast)
    }

    func parseRxVar(overrides: [String: String]?, overrideKey: String, isInitParam: Bool) -> (String, String, String?)? {
        guard (self.isNominal(named: .observable) || self.isNominal(named: .rxObservable)),
              case .nominal(let nominal) = kind,
              !nominal.genericParameterTypes.isEmpty else {
            return nil
        }
        let typeParams = nominal.genericParameterTypes.map(\.description).joined(separator: ", ")

        var subjectKind = ""
        var underlyingSubjectType = ""
        if let rxTypes = overrides {
            if let val = rxTypes[overrideKey], val.hasSuffix(String.subjectSuffix) {
                subjectKind = val
            } else if let val = rxTypes["all"], val.hasSuffix(String.subjectSuffix) {
                subjectKind = val
            }
        }

        if subjectKind.isEmpty {
            subjectKind = String.publishSubject
        }
        underlyingSubjectType = "\(subjectKind)<\(typeParams)>"

        var underlyingSubjectTypeDefaultVal: String? = nil
        if subjectKind == String.publishSubject {
            underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)()"
        } else if subjectKind == String.replaySubject {
            underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)\(String.replaySubjectCreate)"
        } else if subjectKind == String.behaviorSubject {
            if let val = nominal.genericParameterTypes[0].defaultSingularVal(isInitParam: isInitParam, overrides: overrides, overrideKey: overrideKey) {
                underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)(value: \(val))"
            }
        }
        return (underlyingSubjectType, typeParams, underlyingSubjectTypeDefaultVal)

    }
}

extension SwiftTypeNew {
    init(typeSyntax: TypeSyntax) {
        switch typeSyntax.as(TypeSyntaxEnum.self) {
        case .arrayType(let syntax):
            // [T]
            let elementType = SwiftTypeNew(typeSyntax: syntax.element)
            self.kind = .nominal(.init(name: .arrayTypeSugarName, genericParameterTypes: [elementType]))

        case .dictionaryType(let syntax):
            // [T: U]
            let keyType = SwiftTypeNew(typeSyntax: syntax.key)
            let valueType = SwiftTypeNew(typeSyntax: syntax.value)
            self.kind = .nominal(.init(name: .dictionaryTypeSugarName, genericParameterTypes: [keyType, valueType]))

        case .tupleType(let syntax):
            // (T, u: U)
            let elements = syntax.elements.map {
                SwiftTypeNew.Tuple.Element(
                    label: $0.firstName?.text, // Tuple element cannot have two labels
                    type: SwiftTypeNew(typeSyntax: $0.type)
                )
            }
            self.kind = .tuple(.init(elements: elements))

        case .functionType(let syntax):
            // (T) -> U
            self.kind = .closure(.init(
                isAsync: syntax.effectSpecifiers?.asyncSpecifier != nil,
                throwing: ThrowingKind(syntax.effectSpecifiers?.throwsClause),
                arguments: syntax.parameters.map {
                    .init(
                        firstName: $0.firstName?.text,
                        secondName: $0.secondName?.text,
                        type: .init(typeSyntax: $0.type)
                    )
                },
                returning: SwiftTypeNew(typeSyntax: syntax.returnClause.type)
            ))

        case .optionalType(let syntax):
            // T?
            let base = SwiftTypeNew(typeSyntax: syntax.wrappedType)
            self = base.optionalWrapped()

        case .implicitlyUnwrappedOptionalType(let syntax):
            // T!
            let base = SwiftTypeNew(typeSyntax: syntax.wrappedType)
            self = base.optionalWrapped()
            self.isIUO = true

        case .identifierType(let syntax):
            // T<U>
            let name = syntax.name.trimmedDescription
            let generics = syntax.genericArgumentClause?.arguments.compactMap {
                $0.argument.as(TypeSyntax.self).flatMap {
                    SwiftTypeNew(typeSyntax: $0)
                }
            }
            self.kind = .nominal(.init(name: name, genericParameterTypes: generics ?? []))

        case .someOrAnyType(let syntax):
            // some P, any P
            self = SwiftTypeNew(typeSyntax: syntax.constraint)
            self.someOrAny = switch syntax.someOrAnySpecifier.tokenKind {
            case .keyword(.some): .some
            case .keyword(.any): .any
            default: nil
            }

        case .metatypeType(let syntax):
            // T.Type, P.Protocol
            let base = SwiftTypeNew(typeSyntax: syntax.baseType)
            self.kind = .nominal(.init(name: "\(base.description).\(syntax.metatypeSpecifier.text)"))

        case .memberType(let syntax):
            // T.U
            let base = SwiftTypeNew(typeSyntax: syntax.baseType)
            let name = syntax.name.trimmedDescription
            self.kind = .nominal(.init(name: "\(base.description).\(name)"))

        case .attributedType(let syntax):
            // inout T, sending T, @escaping T
            self = SwiftTypeNew(typeSyntax: syntax.baseType)
            self.attributes += syntax.specifiers.map(\.trimmedDescription)
            self.attributes += syntax.attributes.map(\.trimmedDescription)

        case .compositionType(let syntax):
            // P & Q
            let elements = syntax.elements.map { SwiftTypeNew(typeSyntax: $0.type) }
            self.kind = .composition(.init(elements: elements))

        case .namedOpaqueReturnType(let syntax):
            // <U>A
            // unsupported
            self.kind = .nominal(.init(name: syntax.trimmedDescription))

        case .packElementType(let syntax):
            // each T
            self = SwiftTypeNew(typeSyntax: syntax.pack)
            self.attributes.append("each")

        case .packExpansionType(let syntax):
            // repeat T
            self = SwiftTypeNew(typeSyntax: syntax.repetitionPattern)
            self.attributes.insert("repeat", at: 0)

        case .suppressedType(let syntax):
            // unsupported
            self = .init(typeSyntax: syntax.type)

        case .classRestrictionType(let syntax):
            // unsupported
            self.kind = .nominal(.init(name: syntax.trimmedDescription))

        case .missingType(let syntax):
            // unsupported
            self.kind = .nominal(.init(name: syntax.trimmedDescription))
        }
    }

    // escaping hatch. May return corrupted results
    static func make(named: String) -> SwiftTypeNew {
        return .init(kind: .nominal(.init(name: named)))
    }

    func optionalWrapped() -> SwiftTypeNew {
        return copy(
            kind: .nominal(.init(name: .optionalTypeSugarName, genericParameterTypes: [.init(kind: kind)]))
        )
    }

    func optionalUnwrapped() -> SwiftTypeNew? {
        guard isOptional else {
            return nil
        }
        guard case .nominal(let nominal) = kind else {
            return nil
        }
        return nominal.genericParameterTypes.first
    }

    func copy(kind: Kind) -> Self {
        var copy = self
        copy.kind = kind
        return copy
    }
}

extension SwiftTypeNew {
    static let `Any` = SwiftTypeNew(
        kind: .nominal(.init(name: "Any"))
    )
    static let `Void` = SwiftTypeNew(
        kind: .tuple(.init(elements: []))
    )
    static let `Never` = SwiftTypeNew(
        kind: .nominal(.init(name: "Never"))
    )
    static let `Self` = SwiftTypeNew(
        kind: .nominal(.init(name: "Self"))
    )
}
