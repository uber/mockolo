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

func applyClosureTemplate(name: String,
                          type: Type,
                          typeKeys: [String: String]?,
                          genericTypeNames: [String],
                          paramVals: [String]?,
                          paramTypes: [Type]?,
                          suffix: String,
                          returnDefaultType: Type) -> String {
    
    var handlerParamValsStr = ""
    if let paramVals = paramVals, let paramTypes = paramTypes {
        let zipped = zip(paramVals, paramTypes).map { (arg) -> String in
            let (argName, argType) = arg
            if argType.typeName.hasPrefix(String.autoclosure) {
                return argName + "()"
            }
            if argName.isSwiftKeyword {
                return "`\(argName)`"
            }
            return argName
        }
        handlerParamValsStr = zipped.joined(separator: ", ")
    }
    let handlerReturnDefault = renderReturnDefaultStatement(name: name, type: returnDefaultType, typeKeys: typeKeys)

    let prefix = suffix.isThrowsOrRethrows ? String.try + " " : ""
    
    let returnStr = returnDefaultType.typeName.isEmpty ? "" : "return "
    let callExpr = "\(returnStr)\(prefix)\(name)(\(handlerParamValsStr))\(type.cast ?? "")"
    
    let template =
    """
    
            if let \(name) = \(name) {
                \(callExpr)
            }
            \(handlerReturnDefault)
    """

    return template
}


private func renderReturnDefaultStatement(name: String, type: Type, typeKeys: [String: String]?) -> String {
    guard !type.isUnknown else { return "" }

    let result = type.defaultVal(with: typeKeys) ?? String.fatalError
    
    if result.isEmpty {
        return ""
    }
    if result.contains(String.fatalError) {
        return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
    }
    return  "return \(result)"
}
