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

    // Resolved getter-tracking opt-in; `.unspecified` defers to `--enable-getter-history`.
    enum GetterHistory {
        case enabled
        case disabled
        case unspecified
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
    let getterHistory: GetterHistory
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
         getterHistory: GetterHistory,
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
        self.getterHistory = getterHistory
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

extension VariableModel {
    // Combine `AnyPublisher` intercepted by the publisher template (no `_name` backing).
    var isCombineVariable: Bool {
        return type?.isNominal(named: .anyPublisher) == true
    }

    // Rx stream intercepted by the Rx template (`rx:` override or bare `Observable<…>`).
    // Direct `BehaviorSubject`/`ReplaySubject`/`BehaviorRelay` props stay eligible.
    var isRxVariable: Bool {
        if let rxTypes, !rxTypes.isEmpty,
           type?.parseRxVar(overrides: rxTypes, overrideKey: name, isInitParam: true) != nil {
            return true
        }
        return type?.typeName.range(of: String.observableLeftAngleBracket) != nil
    }

    // Protocol-mock stored getters only; intercepted, property-wrapped, weak/dynamic and processed props are excluded.
    func shouldTrackGetter(force: Bool, context: RenderContext) -> Bool {
        guard !processed,
              context.annotatedTypeKind == .protocol,
              case .stored = storageKind,
              !isCombineVariable,
              !isRxVariable,
              propertyWrapper == nil,
              customModifiers?[name] == nil
        else {
            return false
        }
        switch getterHistory {
        case .enabled: return true
        case .disabled: return false
        case .unspecified: return force
        }
    }

    // `_name` when a stored getter is tracked, else the existing name; computed/untracked props are unchanged.
    func backingName(force: Bool, context: RenderContext) -> String {
        guard case .stored = storageKind,
              shouldTrackGetter(force: force, context: context)
        else {
            return underlyingName
        }
        return "\(String.underlyingVarPrefix)\(name)"
    }
}
