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
    let params: [(String, SwiftType)]
    let isAsync: Bool
    let throwing: ThrowingKind

    var modelType: ModelType {
        return .closure
    }

    init(genericTypeParams: [ParamModel], params: [(String, SwiftType)], isAsync: Bool, throwing: ThrowingKind, returnType: SwiftType) {
        // In the mock's call handler, rethrows is unavailable.
        let throwing = throwing.coerceRethrowsToThrows
        self.isAsync = isAsync
        self.throwing = throwing
        self.genericTypeNames = genericTypeParams.map(\.name)
        self.params = params
        self.funcReturnType = returnType
    }

    func type(enclosingType: SwiftType, requiresSendable: Bool) -> SwiftType {
        return SwiftType.toClosureType(
            params: params.map(\.1),
            typeParams: genericTypeNames,
            isAsync: isAsync,
            throwing: throwing,
            returnType: funcReturnType,
            encloser: enclosingType,
            requiresSendable: requiresSendable
        )
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        guard let overloadingResolvedName = context.overloadingResolvedName,
              let enclosingType = context.enclosingType else {
            return nil
        }
        return applyClosureTemplate(type: type(enclosingType: enclosingType, requiresSendable: context.requiresSendable),
                                    name: overloadingResolvedName + .handlerSuffix,
                                    params: params,
                                    returnDefaultType: funcReturnType)
    }
}

