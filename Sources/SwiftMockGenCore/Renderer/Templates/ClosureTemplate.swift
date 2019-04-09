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

func applyClosureTemplate(name: String,
                          type: String,
                          genericTypeNames: [String],
                          paramVals: [String]?,
                          paramTypes: [String]?,
                          returnAs: String,
                          returnDefaultType: String) -> String {
    let handlerParamValsStr = paramVals?.joined(separator: ", ") ?? ""
    let handlerReturnDefault = renderReturnDefaultStatement(name: name, type: returnDefaultType)

    var returnTypeCast = ""
    if !returnAs.isEmpty {
        // TODO: add a better check for optional
        let asSuffix = returnAs.hasSuffix("?") ? "?" : "!"
        returnTypeCast = " as\(asSuffix) " + returnAs
    }
    
    let result = """
        if let \(name) = \(name) {
            return \(name)(\(handlerParamValsStr))\(returnTypeCast)
        }
        \(handlerReturnDefault)
    """
    
    return result
}


private func renderReturnDefaultStatement(name: String, type: String) -> String {
    if type != UnknownVal, !type.isEmpty {
        if type.contains("->") {
            return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
        }
        
        let result = processDefaultVal(typeName: type) ?? String.fatalError
        
        if result.isEmpty {
            return ""
        }
        if result.contains(String.fatalError) {
            return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
        }
        return  "return \(result)"
    }
    return ""
}
