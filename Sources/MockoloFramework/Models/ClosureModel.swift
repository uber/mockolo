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

final class ClosureModel: Model {
    let name: String = "" // closure type cannot have a name
    let offset: Int64 = .max

    let funcReturnType: SwiftType
    let genericTypeNames: [String]
    let paramNames: [String]
    let paramTypes: [SwiftType]
    let isAsync: Bool
    let throwing: ThrowingKind

    var modelType: ModelType {
        return .closure
    }

    init(genericTypeParams: [ParamModel], paramNames: [String], paramTypes: [SwiftType], isAsync: Bool, throwing: ThrowingKind, returnType: SwiftType) {
        // In the mock's call handler, rethrows is unavailable.
        let throwing = throwing.coerceRethrowsToThrows
        self.isAsync = isAsync
        self.throwing = throwing
        self.genericTypeNames = genericTypeParams.map(\.name)
        self.paramNames = paramNames
        self.paramTypes = paramTypes
        self.funcReturnType = returnType
    }

    func type(enclosingType: SwiftType) -> SwiftType {
        return SwiftType.toClosureType(
            params: paramTypes,
            typeParams: genericTypeNames,
            isAsync: isAsync,
            throwing: throwing,
            returnType: funcReturnType,
            encloser: enclosingType
        )
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments = .default
    ) -> String? {
        guard let overloadingResolvedName = context.overloadingResolvedName,
              let enclosingType = context.enclosingType else {
            return nil
        }
        return applyClosureTemplate(type: type(enclosingType: enclosingType),
                                    name: overloadingResolvedName + .handlerSuffix,
                                    paramVals: paramNames,
                                    paramTypes: paramTypes,
                                    returnDefaultType: funcReturnType)
    }
}

