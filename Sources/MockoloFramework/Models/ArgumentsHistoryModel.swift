import Foundation

final class ArgumentsHistoryModel: Model {
    var name: String
    var type: Type
    var offset: Int64 = .max
    let paramNames: [String]
    let paramTypes: [Type]
    let suffix: String
    let isHistoryAnnotated: Bool

    var modelType: ModelType {
        return .class
    }

    init(name: String, genericTypeParams: [ParamModel], paramNames: [String], paramTypes: [Type], isHistoryAnnotated: Bool, suffix: String) {
        self.name = name + .argsHistorySuffix
        self.paramNames = paramNames
        self.paramTypes = paramTypes
        self.suffix = suffix
        self.isHistoryAnnotated = isHistoryAnnotated

        let genericTypeNameList = genericTypeParams.map(path: \.name)
        self.type = Type.toArgumentsHistoryType(with: paramTypes, typeParams: genericTypeNameList)
    }
    
    func needsCaptureHistory(force: Bool) -> Bool {
        return (force || isHistoryAnnotated) && !paramNames.isEmpty
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, captureAllFuncArgsHistory: Bool) -> String? {
        guard needsCaptureHistory(force: captureAllFuncArgsHistory) else {
            return ""
        }
        
        switch paramNames.count {
        case 1:
            return "\(name).append(\(paramNames[0]))"
        case 2...:
            let paramNamesStr = paramNames.joined(separator: ", ")
            return "\(name).append((\(paramNamesStr)))"
        default:
            fatalError("paramNames must not be empty.")
        }
    }
}
