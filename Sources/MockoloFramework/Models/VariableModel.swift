import Foundation

final class VariableModel: Model {
    struct GetterEffects: Equatable {
        var isAsync: Bool
        var throwing: ThrowingKind
        static let empty: GetterEffects = .init(isAsync: false, throwing: .none)
    }

    enum MockStorageKind {
        case stored(needsSetCount: Bool)
        case computed(GetterEffects)
    }

    let name: String
    let type: SwiftType?
    let offset: Int64
    let accessLevel: String
    let attributes: [String]?
    /// Indicates whether this model can be used as a parameter to an initializer
    let canBeInitParam: Bool
    let processed: Bool
    let isStatic: Bool
    let storageKind: MockStorageKind
    let rxTypes: [String: String]?
    let customModifiers: [String: Modifier]?
    let modelDescription: String?

    var combineType: CombineType?
    var wrapperAliasModel: VariableModel?
    var propertyWrapper: String?
    var modelType: ModelType {
        return .variable
    }

    var fullName: String {
        let suffix = isStatic ? String.static : ""
        return name + suffix
    }

    var underlyingName: String {
        if type?.defaultVal() == nil {
            return "_\(name)"
        }
        return name
    }

    init(name: String,
         type: SwiftType?,
         acl: String?,
         isStatic: Bool,
         storageKind: MockStorageKind,
         canBeInitParam: Bool,
         offset: Int64,
         rxTypes: [String: String]?,
         customModifiers: [String: Modifier]?,
         modelDescription: String?,
         combineType: CombineType?,
         processed: Bool) {
        self.name = name
        self.type = type
        self.offset = offset
        self.isStatic = isStatic
        self.storageKind = storageKind
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.rxTypes = rxTypes
        self.customModifiers = customModifiers
        self.accessLevel = acl ?? ""
        self.attributes = nil
        self.modelDescription = modelDescription
        self.combineType = combineType
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        guard let enclosingType = context.enclosingType else {
            return nil
        }
        let shouldOverride = context.annotatedTypeKind == .class
        if processed {
            guard let modelDescription = modelDescription?.trimmingCharacters(in: .newlines), !modelDescription.isEmpty else {
                return nil
            }

            var prefix = ""
            if let propertyWrapper = propertyWrapper, !modelDescription.contains(propertyWrapper) {
                prefix = "\(propertyWrapper) "
            }
            if let type, shouldOverride, !name.isGenerated(type: type) {
                prefix += "\(String.override) "
            }

            return prefix + modelDescription
        }

        guard let type else {
            return nil
        }

        if !arguments.disableCombineDefaultValues {
            if let combineVar = applyCombineVariableTemplate(name: name,
                                                             type: type,
                                                             encloser: enclosingType.typeName,
                                                             shouldOverride: shouldOverride,
                                                             isStatic: isStatic,
                                                             accessLevel: accessLevel) {
                return combineVar
            }
        }

        if let rxVar = applyRxVariableTemplate(name: name,
                                               type: type,
                                               encloser: enclosingType.typeName,
                                               rxTypes: rxTypes,
                                               shouldOverride: shouldOverride,
                                               allowSetCallCount: arguments.allowSetCallCount,
                                               isStatic: isStatic,
                                               accessLevel: accessLevel) {
            return rxVar
        }

        return applyVariableTemplate(name: name,
                                     type: type,
                                     encloser: enclosingType.typeName,
                                     isStatic: isStatic,
                                     customModifiers: customModifiers,
                                     allowSetCallCount: arguments.allowSetCallCount,
                                     shouldOverride: shouldOverride,
                                     accessLevel: accessLevel,
                                     context: context,
                                     arguments: arguments)
    }
}
