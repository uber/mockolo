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
                         kind: MethodKind,
                         isOverride: Bool,
                         genericTypeParams: [ParamModel],
                         params: [ParamModel],
                         returnType: Type,
                         staticKind: String,
                         accessControlLevelDescription: String,
                         suffix: String,
                         handler: ClosureModel?,
                         typeKeys: [String: String]?) -> String {
    var template = ""
    
    let returnTypeName = returnType.isUnknown ? "" : returnType.typeName

    let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription+" "
    let genericTypeDeclsStr = genericTypeParams.compactMap {$0.render(with: "")}.joined(separator: ", ")
    let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
    let paramDeclsStr = params.compactMap{$0.render(with: "")}.joined(separator: ", ")
    
    switch kind {
    case .initKind(let isRequired):
        if isOverride {
            let modifier = isRequired ? "\(String.required) " : (isOverride ? "\(String.override) " : "") 
            let paramsList = params.map { param in
                return "\(param.name): \(param.name.safeName)"
            }.joined(separator: ", ")
            
            template = """
            \(String.spaces4)\(modifier)\(acl)init\(genericTypesStr)(\(paramDeclsStr)) {
            \(String.spaces8)super.init(\(paramsList))
            \(String.spaces8)\(String.doneInit) = true
            \(String.spaces4)}
            """
        } else {
            
            let reqModifier = isRequired ? "\(String.required) " : ""
            
            let paramsAssign = params.map { param in
                return "\(String.spaces8)self.\(param.name) = \(param.name.safeName)"
            }.joined(separator: "\n")
            
            template = """
            \(String.spaces4)\(reqModifier)\(acl)init\(genericTypesStr)(\(paramDeclsStr)) {
            \(paramsAssign)
            \(String.spaces8)\(String.doneInit) = true
            \(String.spaces4)}
            """
        }
        
    default:
        let callCount = "\(identifier)\(String.callCountSuffix)"
        let handlerVarName = "\(identifier)\(String.handlerSuffix)"
        let handlerVarType = handler?.type.typeName ?? "Any"
        let handlerReturn = handler?.render(with: identifier, typeKeys: typeKeys) ?? ""
        
        let suffixStr = suffix.isEmpty ? "" : "\(suffix) "
        let returnStr = returnTypeName.isEmpty ? "" : "-> \(returnTypeName)"
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
        let isSubscript = kind == .subscriptKind
        let keyword = isSubscript ? "" : "func "
        let body =
        """
        \(String.spaces8)\(callCount) += 1
        \(handlerReturn)
        """
            
        let wrapped = !isSubscript ? body :
        """
        \(String.spaces8)get {
        \(body)
        \(String.spaces8)}
        \(String.spaces8)set { }
        """

        let overrideStr = isOverride ? "\(String.override) " : ""
        template =
        """
        \(String.spaces4)\(acl)\(staticStr)var \(callCount) = 0
        \(String.spaces4)\(acl)\(staticStr)var \(handlerVarName): \(handlerVarType)
        \(String.spaces4)\(acl)\(staticStr)\(overrideStr)\(keyword)\(name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnStr) {
        \(wrapped)
        \(String.spaces4)}
        """
    }
 
    return template
}
