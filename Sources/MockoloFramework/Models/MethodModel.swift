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

public enum MethodKind: Equatable {
    case funcKind
    case initKind(required: Bool, override: Bool)
    case subscriptKind
}

final class MethodModel: Model {
    var filePath: String = ""
    var data: Data? = nil
    var name: String
    var type: SwiftType
    var offset: Int64
    let length: Int64
    let accessLevel: String
    var attributes: [String]? = nil
    let genericTypeParams: [ParamModel]
    var genericWhereClause: String? = nil
    let params: [ParamModel]
    let processed: Bool
    var modelDescription: String? = nil
    var isStatic: Bool
    let shouldOverride: Bool
    let suffix: FunctionSuffixClause?
    let kind: MethodKind
    let funcsWithArgsHistory: [String]
    let customModifiers: [String : Modifier]
    var modelType: ModelType {
        return .method
    }

    private var staticKind: String {
        return isStatic ? .static : ""
    }
    
    /// This is used to uniquely identify methods with the same signature and different generic requirements
    var genericWhereClauseToSignatureComponent: String {
        guard let genericWhereClause else {
            return ""
        }
        let typeRequirementSyntax = ":"
        let typeEqualitySyntax = "=="
        
        var signatureComponents: [String] = []
        
        genericWhereClause.deletingPrefix("where").components(separatedBy: ",").forEach { requirement in
            if requirement.contains(typeRequirementSyntax) {
                let components = requirement.components(separatedBy: typeRequirementSyntax).map{ $0.trimmingCharacters(in: .whitespaces) }
                guard let key = components.first, let value = components.last else {
                    return
                }
                let valueDescription = value.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "&", with: "And")
                signatureComponents.append(contentsOf: [key, valueDescription])
            } else if requirement.contains(typeEqualitySyntax) {
                let components = requirement.components(separatedBy: typeEqualitySyntax).map{ $0.trimmingCharacters(in: .whitespaces) }
                guard let key = components.first, let value = components.last else {
                    return
                }
                signatureComponents.append(contentsOf: [key, value])
            }
        }
        
        return signatureComponents.map { component in
            var newComponent = component
            newComponent.removeAll(where: { $0 == "."})
            return newComponent
        }.joined()
    }

    var isInitializer: Bool {
        if case .initKind(_, _) = kind {
            return true
        }
        return false
    }

    var isSubscript: Bool {
        if case .subscriptKind = kind {
            return true
        }
        return false
    }

    lazy var signatureComponents: [String] = {
        let paramLabels = self.params.map {$0.label != "_" ? $0.label : ""}
        let paramNames = self.params.map(\.name)
        let paramTypes = self.params.map(\.type)
        let nameString = self.name
        var args = zip(paramLabels, paramNames).compactMap { (argLabel: String, argName: String) -> String? in
            let val = argLabel.isEmpty ? argName : argLabel
            if val.count < 2 || !nameString.lowercased().hasSuffix(val.lowercased()) {
                return val.capitalizeFirstLetter
            }
            return nil
        }

        let genericTypeNames = self.genericTypeParams.map { $0.name.capitalizeFirstLetter + $0.type.displayName }
        args.append(contentsOf: genericTypeNames)
        if let genericWhereClause {
            args.append(genericWhereClauseToSignatureComponent)
        }
        args.append(contentsOf: paramTypes.map(\.displayName))
        var displayType = self.type.displayName
        let capped = min(displayType.count, 32)
        displayType.removeLast(displayType.count-capped)
        args.append(displayType)
        args.append(self.staticKind)
        let ret = args.filter{ arg in !arg.isEmpty }
        return ret
    }()

    lazy var argsHistory: ArgumentsHistoryModel? = {
        if isInitializer || isSubscript {
            return nil
        }

        let ret = ArgumentsHistoryModel(name: name,
                                        genericTypeParams: genericTypeParams,
                                        params: params,
                                        isHistoryAnnotated: funcsWithArgsHistory.contains(name),
                                        suffix: suffix)

        return ret
    }()

    func handler(encloser: String) -> ClosureModel? {
        if isInitializer {
            return nil
        }

        let paramNames = self.params.map(\.name)
        let paramTypes = self.params.map(\.type)
        let ret = ClosureModel(name: name,
                               genericTypeParams: genericTypeParams,
                               paramNames: paramNames,
                               paramTypes: paramTypes,
                               suffix: suffix,
                               returnType: type,
                               encloser: encloser)

        return ret
    }


    init(name: String,
         typeName: String,
         kind: MethodKind,
         encloserType: DeclType,
         acl: String,
         genericTypeParams: [ParamModel],
         genericWhereClause: String?,
         params: [ParamModel],
         throwsOrRethrows: FunctionThrowsSuffix?,
         asyncOrReasync: FunctionAsyncSuffix?,
         isStatic: Bool,
         offset: Int64,
         length: Int64,
         funcsWithArgsHistory: [String],
         customModifiers: [String: Modifier],
         modelDescription: String?,
         processed: Bool) {
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = SwiftType(typeName.trimmingCharacters(in: .whitespaces))
        self.suffix = FunctionSuffixClause(
            throwsSuffix: throwsOrRethrows,
            asyncSuffix: asyncOrReasync
        )
        self.offset = offset
        self.length = length
        self.kind = kind
        self.isStatic = isStatic
        self.shouldOverride = encloserType == .classType
        self.params = params
        self.genericTypeParams = genericTypeParams
        self.genericWhereClause = genericWhereClause
        self.processed = processed
        self.funcsWithArgsHistory = funcsWithArgsHistory
        self.customModifiers = customModifiers
        self.modelDescription = modelDescription
        self.accessLevel = acl
    }

    var fullName: String {
        return self.name + self.signatureComponents.joined() + staticKind
    }

    func name(by level: Int) -> String {
        if level <= 0 {
            return name
        }
        let diff = level - self.signatureComponents.count
        let postfix = diff > 0 ? String(diff) : self.signatureComponents[level - 1]
        return name(by: level - 1) + postfix
    }

    func render(with identifier: String, encloser: String, useTemplateFunc: Bool, useMockObservable: Bool, allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool, disableCombineDefaultValues: Bool = false) -> String? {
        if processed {
            var prefix = shouldOverride  ? "\(String.override) " : ""

            if case .initKind(required: let isRequired, override: _) = self.kind {
                if isRequired {
                    prefix = ""
                }
            }

            if let ret = modelDescription?.trimmingCharacters(in: .newlines) ?? self.data?.toString(offset: offset, length: length) {
                return prefix + ret
            }
            return nil
        }

        let result = applyMethodTemplate(name: name,
                                         identifier: identifier,
                                         kind: kind,
                                         useTemplateFunc: useTemplateFunc,
                                         allowSetCallCount: allowSetCallCount,
                                         enableFuncArgsHistory: enableFuncArgsHistory,
                                         isStatic: isStatic,
                                         customModifiers: customModifiers,
                                         isOverride: shouldOverride,
                                         genericTypeParams: genericTypeParams,
                                         genericWhereClause: genericWhereClause,
                                         params: params,
                                         returnType: type,
                                         accessLevel: accessLevel,
                                         suffix: suffix,
                                         argsHistory: argsHistory,
                                         handler: handler(encloser: encloser))
        return result
    }
}

/// throws, rethrows
///
/// if throws clause has a type information, the associated value `type` is not `nil`.
struct FunctionThrowsSuffix {
    let isRethrows: Bool
    let type: String?
}

/// async, reasync
struct FunctionAsyncSuffix {
    var isReasync: Bool

    var text: String {
        isReasync ? String.reasync : String.async
    }

    var description: String {
        text
    }
}

/// Function Suffix Clause such as async / throws.
///
/// Since the support of typed throw, it is necessary to prepare a type that represents suffix in place of String type
/// due to the swift syntax's complexity.
struct FunctionSuffixClause {
    var throwsSuffix: FunctionThrowsSuffix?
    var asyncSuffix: FunctionAsyncSuffix?


    init?(throwsSuffix: FunctionThrowsSuffix? = nil, asyncSuffix: FunctionAsyncSuffix? = nil) {
        if throwsSuffix == nil, asyncSuffix == nil {
            return nil
        }
        self.throwsSuffix = throwsSuffix
        self.asyncSuffix = asyncSuffix
    }
}
