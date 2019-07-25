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

func applyMethodTemplate(name: String,
                         identifier: String,
                         isInitializer: Bool,
                         genericTypeParams: [ParamModel],
                         params: [ParamModel],
                         returnType: String,
                         staticKind: String,
                         accessControlLevelDescription: String,
                         suffix: String,
                         handler: ClosureModel?,
                         typeKeys: [String: String]?) -> String {
    var template = ""
    
    let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription+" "
    let genericTypeDeclsStr = genericTypeParams.compactMap {$0.render(with: "")}.joined(separator: ", ")
    let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
    let paramDeclsStr = params.compactMap{$0.render(with: "")}.joined(separator: ", ")

    if isInitializer {
        let paramsAssign = params.map { param in
            return """
                self.\(param.name) = \(param.name)
            """
            }.joined(separator: "\n")
        template = """
        
        \(String.required) \(acl)init\(genericTypesStr)(\(paramDeclsStr)) {
        \(paramsAssign)
        }
    """
    } else {
        let callCount = "\(identifier)\(String.callCountSuffix)"
        let handlerVarName = "\(identifier)\(String.handlerSuffix)"
        let handlerVarType = handler?.type ?? "Any"
        let handlerReturn = handler?.render(with: identifier, typeKeys: typeKeys) ?? ""
        
        let suffixStr = suffix.isEmpty ? "" : "\(suffix) "
        let returnStr = returnType.isEmpty ? "" : "-> \(returnType)"
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
        template = """
        
        \(staticStr)var \(callCount) = 0
        \(acl)\(staticStr)var \(handlerVarName): \(handlerVarType)
        \(acl)\(staticStr)func \(name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnStr) {
            \(callCount) += 1
        \(handlerReturn)
        }
    """
    }
    return template
}

private func renderMethodParamNames(_ elements: [Structure], capitalized: Bool) -> [String] {
    return elements.map { (element: Structure) -> String in
        return capitalized ? element.name.capitlizeFirstLetter : element.name
    }
}

