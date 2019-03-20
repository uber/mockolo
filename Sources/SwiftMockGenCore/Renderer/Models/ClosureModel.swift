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
import SourceKittenFramework

struct ClosureModel: Model {
    var name: String
    var type: String
    var offset: Int64 = .max
    let returnAs: String
    let defaultReturnType: String
    let staticKind: String
    let genericTypeNames: [String]
    let paramNames: [String]
    let paramTypes: [String]
    
    init(name: String, genericTypeParams: [ParamModel], paramNames: [String], paramTypes: [String], returnType: String, staticKind: String) {
        self.name = name + .handlerSuffix
        self.staticKind = staticKind

        let genericTypeNameList = genericTypeParams.map(path: \.name)
        self.paramNames = paramNames
        self.paramTypes = paramTypes
        let displayableParamTypes = paramTypes.map { (subtype: String) -> String in
            let hasGenericType = genericTypeNameList.filter{ (item: String) -> Bool in
                subtype.displayableComponents.contains(item)
            }
            return hasGenericType.isEmpty ? subtype : .any
        }
        
        self.genericTypeNames = genericTypeNameList
        let displayableParamStr = displayableParamTypes.joined(separator: ", ")
        let funcReturnType = returnType == UnknownVal ? "" : returnType
        var displayableReturnType = funcReturnType
        let returnComps = funcReturnType.displayableComponents
        
        var returnAsStr = ""
        if !genericTypeNameList.filter({returnComps.contains($0)}).isEmpty {
            displayableReturnType = .any
            returnAsStr = funcReturnType
        }

        let isSimpleTuple = displayableReturnType.hasPrefix("(") &&
            displayableReturnType.hasSuffix(")") &&
            displayableReturnType.components(separatedBy: CharacterSet(charactersIn: "()")).filter({!$0.isEmpty}).count <= 1
        
        if !isSimpleTuple {
            displayableReturnType = "(\(displayableReturnType))"
        }
        self.type = "((\(displayableParamStr)) -> \(displayableReturnType))?"
        self.defaultReturnType = displayableReturnType
        self.returnAs = returnAsStr
    }
    
    func render(with identifier: String) -> String? {
        return applyClosureTemplate(name: identifier + .handlerSuffix,
                                    type: type,
                                    genericTypeNames: genericTypeNames,
                                    paramVals: paramNames,
                                    paramTypes: paramTypes,
                                    returnAs: returnAs,
                                    returnDefaultType: defaultReturnType)
    }
}
