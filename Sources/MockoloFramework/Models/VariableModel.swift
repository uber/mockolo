import Foundation

final class VariableModel: Model {
    var name: String
    var type: Type
    var offset: Int64
    var length: Int64
    let accessLevel: String
    let attributes: [String]?
    var canBeInitParam: Bool
    let processed: Bool
    var data: Data? = nil
    var filePath: String = ""
    var isStatic = false
    var shouldOverride = false
    var overrideTypes: [String: String]?
    var modifiers: [String: Modifier]?
    var cachedDefaultTypeVal: String?
    var modelDescription: String? = nil
    var modelType: ModelType {
        return .variable
    }

    var fullName: String {
        let suffix = isStatic ? String.static : ""
        return name + suffix
    }

    var underlyingName: String {
        if isStatic || type.defaultVal() == nil {
            return "_\(name)"
        }
        return name
    }

    init(name: String,
         typeName: String,
         acl: String?,
         encloserType: DeclType,
         isStatic: Bool,
         canBeInitParam: Bool,
         offset: Int64,
         length: Int64,
         overrideTypes: [String: String]?,
         modifiers: [String: Modifier]?,
         modelDescription: String?,
         processed: Bool) {
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = Type(typeName.trimmingCharacters(in: .whitespaces))
        self.offset = offset
        self.length = length
        self.isStatic = isStatic
        self.shouldOverride = encloserType == .classType
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.overrideTypes = overrideTypes
        self.modifiers = modifiers
        self.accessLevel = acl ?? ""
        self.attributes = nil
        self.modelDescription = modelDescription
    }

    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false) -> String? {
        if processed {
            var prefix = ""
            if shouldOverride, !name.isGenerated(type: type) {
                prefix = "\(String.override) "
            }
            if let modelDescription = modelDescription?.trimmingCharacters(in: .newlines), !modelDescription.isEmpty {
                return prefix + modelDescription
            }

            if let ret = self.data?.toString(offset: self.offset, length: self.length) {
                if !ret.contains(identifier),
                    let first = ret.components(separatedBy: CharacterSet(arrayLiteral: ":", "=")).first,
                    let found = first.components(separatedBy: " ").filter({!$0.isEmpty}).last {
                    let replaced = ret.replacingOccurrences(of: found, with: identifier)
                    return prefix + replaced
                }
                return prefix + ret
            }
            return nil
        }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               type: type,
                                               encloser: encloser,
                                               overrideTypes: overrideTypes,
                                               shouldOverride: shouldOverride,
                                               useMockObservable: useMockObservable,
                                               allowSetCallCount: allowSetCallCount,
                                               isStatic: isStatic,
                                               accessLevel: accessLevel) {
            return rxVar
        }

        let modifier: Modifier
        if let modifiers = self.modifiers,
           let overrideModifier: Modifier = modifiers[identifier] {
            modifier = overrideModifier
        } else {
            modifier = .none
        }

        return applyVariableTemplate(name: identifier,
                                     type: type,
                                     encloser: encloser,
                                     isStatic: isStatic,
                                     modifier: modifier,
                                     allowSetCallCount: allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel)
    }
}
