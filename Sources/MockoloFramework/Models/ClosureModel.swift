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
    var name: String
    var type: SwiftType
    var offset: Int64 = .max
    let funcReturnType: SwiftType
    let genericTypeNames: [String]
    let paramNames: [String]
    let paramTypes: [SwiftType]
    let suffix: FunctionSuffixClause?

    var modelType: ModelType {
        return .closure
    }

    
    init(name: String, genericTypeParams: [ParamModel], paramNames: [String], paramTypes: [SwiftType], suffix: FunctionSuffixClause?, returnType: SwiftType, encloser: String) {
        self.name = name + .handlerSuffix
        self.suffix = suffix
        let genericTypeNameList = genericTypeParams.map(\.name)
        self.genericTypeNames = genericTypeNameList
        self.paramNames = paramNames
        self.paramTypes = paramTypes
        self.funcReturnType = returnType
        self.type = SwiftType.toClosureType(with: paramTypes, typeParams: genericTypeNameList, suffix: suffix, returnType: returnType, encloser: encloser)
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, allowSetCallCount: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false, disableCombineDefaultValues: Bool = false) -> String? {
        return applyClosureTemplate(name: identifier + .handlerSuffix,
                                    type: type,
                                    genericTypeNames: genericTypeNames,
                                    paramVals: paramNames,
                                    paramTypes: paramTypes,
                                    suffix: suffix,
                                    returnDefaultType: funcReturnType)
    }
}

