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

func renderProperties(_ element: Structure) -> String {
    var str = ""
    if element.isVariable {
        let underlying = "underlying_\(element.name)"
        var subTypeName = element.typeName.replacingOccurrences(of: "?", with: "!")
        if subTypeName == element.typeName {
            subTypeName = subTypeName + "!"
        }
        
        str = """
        var \(underlying): \(subTypeName)
        var \(element.name): \(element.typeName) {
            get {
                return \(underlying)
            }
            set {
                \(underlying) = value
            }
        }
        
        """
    } else if element.isMethod {
        // TODO: handle genetics, observable etc
        if let methodName = element.name.components(separatedBy: "(").first {
            let params = element.substructures.map({ (el: Structure) -> String in
                if el.isParameter {
                    return "\(el.name): \(el.typeName)"
                }
                return ""
            })
            let paramNames = element.substructures.map({ (el: Structure) -> String in
                if el.isParameter {
                    return el.name == "Unknown" ? "_arg" : "_\(el.name)"
                }
                return ""
            })
            let paramStr = params.joined(separator: ", ")
            let paramNameStr = paramNames.joined()
            let methodLongName = methodName + paramNameStr
            let callCount = "\(methodLongName)_callCount"
            let returnStr = element.typeName != "Unknown" ? "-> \(element.typeName)" : ""
            str = """
            var \(callCount) = 0
            func \(methodName)(\(paramStr)) \(returnStr) {
                \(callCount) += 1
            }
            
            """
        }
    }
    
    return str
}
