import Foundation

final class ArgumentsHistoryModel: Model {
    var name: String
    var type: SwiftType
    var offset: Int64 = .max
    let suffix: String
    let capturableParamNames: [String]
    let capturableParamTypes: [SwiftType]
    let isHistoryAnnotated: Bool

    var modelType: ModelType {
        return .class
    }

    init?(name: String, genericTypeParams: [ParamModel], params: [ParamModel], isHistoryAnnotated: Bool, suffix: String) {
        // Value contains closure is not supported.
        let capturables = params.filter { !$0.type.hasClosure && !$0.type.isEscaping && !$0.type.isAutoclosure }
        guard !capturables.isEmpty else {
            return nil
        }
        
        self.name = name + .argsHistorySuffix
        self.suffix = suffix
        self.isHistoryAnnotated = isHistoryAnnotated

        self.capturableParamNames = capturables.map(\.name.safeName)
        self.capturableParamTypes = capturables.map(\.type)
        
        let genericTypeNameList = genericTypeParams.map(\.name)
        self.type = SwiftType.toArgumentsHistoryType(with: capturableParamTypes, typeParams: genericTypeNameList)
    }
    
    func enable(force: Bool) -> Bool {
        return force || isHistoryAnnotated
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool, disableCombineDefaultValues: Bool = false) -> String? {
        guard enable(force: enableFuncArgsHistory) else {
            return nil
        }
        
        switch capturableParamNames.count {
        case 1:
            return "\(identifier)\(String.argsHistorySuffix).append(\(capturableParamNames[0]))"
        case 2...:
            let paramNamesStr = capturableParamNames.joined(separator: ", ")
            return "\(identifier)\(String.argsHistorySuffix).append((\(paramNamesStr)))"
        default:
            fatalError("paramNames must not be empty.")
        }
    }
}
