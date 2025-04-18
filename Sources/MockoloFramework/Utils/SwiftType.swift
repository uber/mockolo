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

struct SwiftTypeNew: CustomStringConvertible {
    enum Kind {
        case tuple(Tuple)
        case nominal(Nominal)
        case closure(Closure)
    }

    struct Tuple {
        var elements: [SwiftTypeNew]
    }

    struct Nominal {
        var name: String
        var genericParameterTypes: [SwiftTypeNew] = []
    }

    struct Closure {
        var atAttributes: [String]
        var isAsync: Bool
        var throwing: ThrowingKind
        var arguments: [SwiftTypeNew]
        var returning: Box<SwiftTypeNew>
    }

    var kind: Kind
    var isInOut: Bool = false
    var isIUO: Bool = false
    var hasEllipsis: Bool = false

    var typeName: String {
        description
    }

    var description: String {
        var repr: String
        switch kind {
        case .tuple(let tuple):
            let elementTypes = tuple.elements.map(\.description)
            repr = "(\(elementTypes.joined(separator: ", ")))"
        case .nominal(let nominal):
            repr = "\(nominal.name)"
            if !nominal.genericParameterTypes.isEmpty {
                let parameterTypes = nominal.genericParameterTypes.map(\.description)
                repr += "<\(parameterTypes.joined(separator: ", "))>"
            }
        case .closure(let closure):
            repr = "TODO"
        }
        if isIUO {
            switch kind {
            case .tuple, .nominal:
                repr += "!"
            case .closure:
                repr = "(\(repr))!"
            }
        }
        if isInOut {
            repr = "inout \(repr)"
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

    var isOptional: Bool {
        isNominal(named:  "Optional")
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

    var isEscaping: Bool {
        if case .closure(let closure) = kind {
            return closure.atAttributes.contains(where: { $0 == "escaping" })
        } else {
            return false
        }
    }

    var isAutoclosure: Bool {
        if case .closure(let closure) = kind {
            return closure.atAttributes.contains(where: { $0 == "autoclosure" })
        } else {
            return false
        }
    }

    var underlyingType: String {
        "TODO"
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
        fatalError("TODO")
    }

    func processTypeParams(with typeParamList: [String]) -> String {
        fatalError("TODO")
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
        fatalError("TODO")
    }

    func parseRxVar(overrides: [String: String]?, overrideKey: String, isInitParam: Bool) -> (String?, String?, String?) {
        fatalError("TODO")
    }

    static var customDefaultValueMap: [String: String]?
}

extension SwiftTypeNew {
    init(typeSyntax: TypeSyntax) {
        //        if let syntax = typeSyntax.as(TypeSyntaxEnum.Type)
        kind = .nominal(.init(name: "", genericParameterTypes: []))
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
}

extension SwiftTypeNew {
    static let `Any` = SwiftTypeNew(
        kind: .nominal(.init(name: "Any"))
    )
    static let `Void` = SwiftTypeNew(
        kind: .tuple(.init(elements: []))
    )
}
