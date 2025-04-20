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
        var arguments: [SwiftTypeNew]
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
            let elementTypes = tuple.elements.map(\.type.description)
            repr += "(\(elementTypes.joined(separator: ", ")))"
        case .nominal(let nominal):
            repr += nominal.name
            if !nominal.genericParameterTypes.isEmpty {
                let parameterTypes = nominal.genericParameterTypes.map(\.description)
                repr += "<\(parameterTypes.joined(separator: ", "))>"
            }
        case .closure(let closure):
            let params = closure.arguments.map(\.description).joined(separator: ", ")

            var closureDesc = "(\(params))"
            if closure.isAsync {
                closureDesc += " async"
            }
            if let throwing = closure.throwing.applyThrowingTemplate() {
                closureDesc += " \(throwing)"
            }
            if !closure.returning.isVoid {
                closureDesc += " -> \(closure.returning.description)"
            }
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
            return closure.arguments.flatMap { $0.includingIdentifiers() } + closure.returning.includingIdentifiers()
        case .composition(let composition):
            return composition.elements.flatMap { $0.includingIdentifiers() }
        }
    }

    var isOptional: Bool {
        isNominal(named: .optional)
    }

    var isSelf: Bool {
        isNominal(named: .Self)
    }

    var isVoid: Bool {
        if case .tuple(let tuple) = kind {
            return tuple.elements.isEmpty
        } else {
            return false
        }
    }

    var isClosure: Bool {
        if case .closure = kind {
            return true
        } else {
            return false
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

        // Use force unwrapped for the underlying type so it doesn't always have to be set in the init (need to allow blank init).
        if isClosure || someOrAny == .any {
            ret = ret.copy(
                kind: .tuple(.init(elements: [.init(type: .init(kind: ret.kind))]))
            )
        } else {
            if let unwrapped = ret.optionalUnwrapped() {
                ret = unwrapped
            }
        }
        ret.isIUO = true

        return ret.description
    }

    // FIXME: remove this
    var isUnknown: Bool {
        typeName == ""
    }

    func defaultVal(with overrides: [String: String]? = nil, overrideKey: String = "", isInitParam: Bool = false) -> String? {
        // TODO:
        return nil
    }

    static func toArgumentsCaptureType(with params: [(label: String, type: SwiftTypeNew)], typeParams: [String]) -> SwiftTypeNew {
        assert(!params.isEmpty)

        // Expected only history capturable types.
        let displayableParamTypes = params.map { $0.type }.compactMap { (subtype: SwiftTypeNew) -> SwiftTypeNew? in
            var processedType = subtype.processTypeParams(with: typeParams)

            if subtype.isInOut {
                processedType.attributes.removeAll(where: { $0 == .inout })
            }
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
        switch kind {
        case .tuple(let tuple):
            return self.copy(kind: .tuple(.init(
                elements: tuple.elements.map {
                    .init(label: $0.label, type: $0.type.processTypeParams(with: typeParamList))
                }
            )))
        case .nominal:
            let hasGenericType: Bool
            if self.someOrAny == .some {
                hasGenericType = true
            } else {
                let typeIDs = includingIdentifiers()
                hasGenericType = typeParamList.contains(where: { typeIDs.contains($0) })
            }

            if hasGenericType {
                if isOptional {
                    return self.copy(kind: SwiftType.Any.optionalWrapped().kind)
                } else {
                    return self.copy(kind: SwiftType.Any.kind)
                }
            } else {
                return self
            }
        case .closure(var closure):
            closure.arguments = closure.arguments.map { $0.processTypeParams(with: typeParamList) }
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
            let returnAsType: SwiftType?

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
                returnAsType = nil
                displayableReturnType = .Any
            }

            if let returnAsType {
                returnTypeCast = " as\(asSuffix) " + returnAsType.displayName
            }
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
                isAsync: false,
                throwing: .none,
                arguments: params,
                returning: displayableReturnType
            ))
        )
        if requiresSendable {
            resultType.attributes.append("@Sendable")
        }
        return (type: resultType, cast: returnTypeCast)
    }

    func parseRxVar(overrides: [String: String]?, overrideKey: String, isInitParam: Bool) -> (String?, String?, String?) {
        guard (self.isNominal(named: .observable) || self.isNominal(named: .rxObservable)),
              case .nominal(let nominal) = kind,
              let typeParam = nominal.genericParameterTypes.first else {
            return (nil, nil, nil)
        }

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
        underlyingSubjectType = "\(subjectKind)<\(typeParam)>"

        var underlyingSubjectTypeDefaultVal: String? = nil
        if subjectKind == String.publishSubject {
            underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)()"
        } else if subjectKind == String.replaySubject {
            underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)\(String.replaySubjectCreate)"
        } else if subjectKind == String.behaviorSubject {
            if let val = typeParam.defaultSingularVal(isInitParam: isInitParam, overrides: overrides, overrideKey: overrideKey) {
                underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)(value: \(val))"
            }
        }
        return (underlyingSubjectType, typeParam.description, underlyingSubjectTypeDefaultVal)

    }

    static var customDefaultValueMap: [String: String]?
}

extension SwiftTypeNew {
    init(typeSyntax: TypeSyntax) {
        switch typeSyntax.as(TypeSyntaxEnum.self) {
        case .arrayType(let syntax):
            // [T]
            let elementType = SwiftTypeNew(typeSyntax: syntax.element)
            self.kind = .nominal(.init(name: "Array", genericParameterTypes: [elementType]))

        case .dictionaryType(let syntax):
            // [T: U]
            let keyType = SwiftTypeNew(typeSyntax: syntax.key)
            let valueType = SwiftTypeNew(typeSyntax: syntax.value)
            self.kind = .nominal(.init(name: "Dictionary", genericParameterTypes: [keyType, valueType]))

        case .tupleType(let syntax):
            // (T, u: U)
            let elements = syntax.elements.map {
                SwiftTypeNew.Tuple.Element(
                    label: $0.firstName?.text, // tuple cannot have secondName
                    type: SwiftTypeNew(typeSyntax: $0.type)
                )
            }
            self.kind = .tuple(.init(elements: elements))

        case .functionType(let syntax):
            // (T) -> U
            self.kind = .closure(.init(
                isAsync: syntax.effectSpecifiers?.asyncSpecifier != nil,
                throwing: ThrowingKind(syntax.effectSpecifiers?.throwsClause),
                arguments: syntax.parameters.map { SwiftType(typeSyntax: $0.type) },
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
            let generics = syntax.genericArgumentClause?.arguments.map { SwiftTypeNew(typeSyntax: $0.argument) }
            self.kind = .nominal(.init(name: name, genericParameterTypes: generics ?? []))

        case .someOrAnyType(let syntax):
            // some P, any P
            self = SwiftTypeNew(typeSyntax: syntax.constraint)
            if syntax.someOrAnySpecifier.tokenKind == .keyword(.some) {
                self.someOrAny = .some
            } else if syntax.someOrAnySpecifier.tokenKind == .keyword(.any) {
                self.someOrAny = .any
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
            // inout T, sending T
            self = SwiftTypeNew(typeSyntax: syntax.baseType)
            self.attributes = syntax.specifiers.map(\.trimmedDescription)

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

    static func makeOrVoid(typeSyntax: TypeSyntax?) -> SwiftTypeNew {
        if let typeSyntax {
            return .init(typeSyntax: typeSyntax)
        } else {
            return .Void
        }
    }

    // escaping hatch. May return corrupted results
    static func make(named: String) -> SwiftTypeNew {
        return .init(kind: .nominal(.init(name: named)))
    }

    func optionalWrapped() -> SwiftTypeNew {
        return copy(
            kind: .nominal(.init(name: .optional, genericParameterTypes: [.init(kind: kind)]))
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
