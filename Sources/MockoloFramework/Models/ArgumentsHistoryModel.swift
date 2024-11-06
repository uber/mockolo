import Foundation

final class ArgumentsHistoryModel: Model {
    let name: String
    let type: SwiftType
    let offset: Int64 = .max
    let capturableParamNames: [String]
    let capturableParamTypes: [SwiftType]
    let isHistoryAnnotated: Bool

    var modelType: ModelType {
        return .argumentsHistory
    }

    init?(name: String, genericTypeParams: [ParamModel], params: [ParamModel], isHistoryAnnotated: Bool) {
        // Value contains closure is not supported.
        let capturables = params.filter { !$0.type.hasClosure && !$0.type.isEscaping && !$0.type.isAutoclosure }
        guard !capturables.isEmpty else {
            return nil
        }
        
        self.name = name + .argsHistorySuffix
        self.isHistoryAnnotated = isHistoryAnnotated

        self.capturableParamNames = capturables.map(\.name.safeName)
        self.capturableParamTypes = capturables.map(\.type)
        
        let genericTypeNameList = genericTypeParams.map(\.name)
        self.type = SwiftType.toArgumentsHistoryType(with: capturableParamTypes, typeParams: genericTypeNameList)
    }
    
    func enable(force: Bool) -> Bool {
        return force || isHistoryAnnotated
    }
    
    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        guard enable(force: arguments.enableFuncArgsHistory) else {
            return nil
        }
        guard let overloadingResolvedName = context.overloadingResolvedName else {
            return nil
        }
        
        switch capturableParamNames.count {
        case 1:
            return "\(overloadingResolvedName)\(String.argsHistorySuffix).append(\(capturableParamNames[0]))"
        case 2...:
            let paramNamesStr = capturableParamNames.joined(separator: ", ")
            return "\(overloadingResolvedName)\(String.argsHistorySuffix).append((\(paramNamesStr)))"
        default:
            fatalError("paramNames must not be empty.")
        }
    }
}
