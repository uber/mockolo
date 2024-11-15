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

final class ArgumentsHistoryModel: Model {
    let name: String
    let capturedValueType: SwiftType
    let offset: Int64 = .max
    let capturableParams: [(String, SwiftType)]
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

        self.capturableParams = capturables.map { ($0.name.safeName, $0.type) }
        
        let genericTypeNameList = genericTypeParams.map(\.name)
        self.capturedValueType = SwiftType.toArgumentsCaptureType(with: capturableParams.map(\.1), typeParams: genericTypeNameList)
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
        
        switch capturableParams.count {
        case 1:
            return "\(overloadingResolvedName)\(String.argsHistorySuffix).append(\(capturableParams[0].0))"
        case 2...:
            let paramNamesStr = capturableParams.map(\.0).joined(separator: ", ")
            return "\(overloadingResolvedName)\(String.argsHistorySuffix).append((\(paramNamesStr)))"
        default:
            fatalError("paramNames must not be empty.")
        }
    }
}
