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
    var type: Type
    var offset: Int64 = .max
    let funcReturnType: Type
    let genericTypeNames: [String]
    let paramNames: [String]
    let paramTypes: [Type]
    let suffix: String

    var modelType: ModelType {
        return .class
    }

    
    init(name: String, genericTypeParams: [ParamModel], paramNames: [String], paramTypes: [Type], suffix: String, returnType: Type, encloser: String) {
        self.name = name + .handlerSuffix
        self.suffix = suffix
        let genericTypeNameList = genericTypeParams.map(path: \.name)
        self.genericTypeNames = genericTypeNameList
        self.paramNames = paramNames
        self.paramTypes = paramTypes
        self.funcReturnType = returnType
        self.type = Type.toClosureType(with: paramTypes, typeParams: genericTypeNameList, suffix: suffix, returnType: returnType, encloser: encloser)
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false) -> String? {
        return applyClosureTemplate(name: identifier + .handlerSuffix,
                                    type: type,
                                    genericTypeNames: genericTypeNames,
                                    paramVals: paramNames,
                                    paramTypes: paramTypes,
                                    suffix: suffix,
                                    returnDefaultType: funcReturnType)
    }
}

