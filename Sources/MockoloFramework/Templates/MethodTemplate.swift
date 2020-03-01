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
            \(1.tab)\(modifier)\(acl)init\(genericTypesStr)(\(paramDeclsStr)) {
            \(2.tab)super.init(\(paramsList))
            \(2.tab)\(String.doneInit) = true
            \(1.tab)}
            """
        } else {
            
            let reqModifier = isRequired ? "\(String.required) " : ""
            
            let paramsAssign = params.map { param in
                return "\(2.tab)self.\(param.name) = \(param.name.safeName)"
            }.joined(separator: "\n")
            
            template = """
            \(1.tab)\(reqModifier)\(acl)init\(genericTypesStr)(\(paramDeclsStr)) {
            \(paramsAssign)
            \(2.tab)\(String.doneInit) = true
            \(1.tab)}
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
        \(2.tab)\(callCount) += 1
        \(handlerReturn)
        """
            
        let wrapped = !isSubscript ? body :
        """
        \(2.tab)get {
        \(body)
        \(2.tab)}
        \(2.tab)set { }
        """

        let overrideStr = isOverride ? "\(String.override) " : ""
        template =
        """
        \(1.tab)\(acl)\(staticStr)var \(callCount) = 0
        \(1.tab)\(acl)\(staticStr)var \(handlerVarName): \(handlerVarType)
        \(1.tab)\(acl)\(staticStr)\(overrideStr)\(keyword)\(name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnStr) {
        \(wrapped)
        \(1.tab)}
        """
    }
 
    return template
}
