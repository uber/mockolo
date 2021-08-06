import Foundation

final class VariableModel: Model {
    var name: String
    var type: Type
    var offset: Int64
    let accessLevel: String
    let attributes: [String]?
    let encloserType: DeclType
    var canBeInitParam: Bool
    let processed: Bool
    var filePath: String = ""
    var isStatic = false
    var shouldOverride = false
    var overrideTypes: [String: String]?
    var modelDescription: String? = nil
    var combineSubjectType: CombineSubjectType?
    var combinePublishedAlias: String?
    var publishedAliasModel: VariableModel?
    var isCombinePublishedAlias: Bool = false
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
         overrideTypes: [String: String]?,
         modelDescription: String?,
         combineSubjectType: CombineSubjectType?,
         combinePublishedAlias: String?,
         processed: Bool) {
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = Type(typeName.trimmingCharacters(in: .whitespaces))
        self.offset = offset
        self.isStatic = isStatic
        self.shouldOverride = encloserType == .classType
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.overrideTypes = overrideTypes
        self.accessLevel = acl ?? ""
        self.attributes = nil
        self.encloserType = encloserType
        self.modelDescription = modelDescription
        self.combineSubjectType = combineSubjectType
        self.combinePublishedAlias = combinePublishedAlias
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

            return nil
        }

        if let combineVar = applyCombineVariableTemplate(name: identifier,
                                                         type: type,
                                                         encloser: encloser,
                                                         shouldOverride: shouldOverride,
                                                         allowSetCallCount: allowSetCallCount,
                                                         isStatic: isStatic,
                                                         accessLevel: accessLevel) {
            return combineVar
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

        return applyVariableTemplate(name: identifier,
                                     type: type,
                                     encloser: encloser,
                                     isStatic: isStatic,
                                     allowSetCallCount: allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel)
    }
}
