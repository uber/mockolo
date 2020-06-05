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

extension MethodModel {
    func applyMethodTemplate(name: String,
                             identifier: String,
                             kind: MethodKind,
                             useTemplateFunc: Bool,
                             captureAllFuncArgsHistory: Bool,
                             isStatic: Bool,
                             isOverride: Bool,
                             genericTypeParams: [ParamModel],
                             params: [ParamModel],
                             returnType: Type,
                             accessLevel: String,
                             suffix: String,
                             handler: ClosureModel?) -> String {
        var template = ""
        
        let returnTypeName = returnType.isUnknown ? "" : returnType.typeName
        
        let acl = accessLevel.isEmpty ? "" : accessLevel+" "
        let genericTypeDeclsStr = genericTypeParams.compactMap {$0.render(with: "", encloser: "")}.joined(separator: ", ")
        let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
        let paramDeclsStr = params.compactMap{$0.render(with: "", encloser: "")}.joined(separator: ", ")
        
        switch kind {
        case .initKind(_, _):  // ClassTemplate needs to handle this as it needs a context of all the vars
            return ""
        default:
            
            guard let handler = handler else { return "" }
            
            let callCount = "\(identifier)\(String.callCountSuffix)"
            let argsHistoryVarName = "\(identifier)\(String.argsHistorySuffix)"
            let argsHistoryVarType = Type.toArgumentsHistoryType(with: params.map(path: \.type), typeParams: genericTypeParams.map(path: \.name)).typeName
            let handlerVarName = "\(identifier)\(String.handlerSuffix)"
            let handlerVarType = handler.type.typeName // ?? "Any"
            let handlerReturn = handler.render(with: identifier, encloser: "") ?? ""
            
            let suffixStr = suffix.isEmpty ? "" : "\(suffix) "
            let returnStr = returnTypeName.isEmpty ? "" : "-> \(returnTypeName)"
            let staticStr = isStatic ? String.static + " " : ""
            let isSubscript = kind == .subscriptKind
            let keyword = isSubscript ? "" : "func "
            var body = ""

            if useTemplateFunc {
                let callMockFunc = !suffix.isThrowsOrRethrows && (handler.type.cast?.isEmpty ?? false)
                if callMockFunc {
                    let handlerParamValsStr = params.map { (arg) -> String in
                        if arg.type.typeName.hasPrefix(String.autoclosure) {
                            return arg.name.safeName + "()"
                        }
                        return arg.name.safeName
                    }.joined(separator: ", ")

                    let defaultVal = type.defaultVal() // ?? "nil"

                    var mockReturn = ".error"
                    if returnType.typeName.isEmpty {
                        mockReturn = ".void"
                    } else if let val = defaultVal {
                        mockReturn = ".val(\(val))"
                    }

                    body = """
                    \(2.tab)mockFunc(&\(callCount))(\"\(name)\", \(handlerVarName)?(\(handlerParamValsStr)), \(mockReturn))
                    """
                }
            }

            if body.isEmpty {
                body = """
                \(2.tab)\(callCount) += 1
                """
                
                if captureAllFuncArgsHistory {
                    switch params.count {
                    case 1:
                        body = """
                        \(body)
                        \(2.tab)\(argsHistoryVarName).append(\(params[0].name))
                        """
                    case 2...:
                        body = """
                        \(body)
                        \(2.tab)\(argsHistoryVarName).append((\(params.map(path: \.name).joined(separator: ", "))))
                        """
                    default:
                        break
                    }
                }

                body = """
                \(body)
                \(handlerReturn)
                """
            }

            var wrapped = body
            if isSubscript {
                wrapped = """
                \(2.tab)get {
                \(body)
                \(2.tab)}
                \(2.tab)set { }
                """
            }
            
            let overrideStr = isOverride ? "\(String.override) " : ""

            template = """

            \(1.tab)\(acl)\(staticStr)var \(callCount) = 0
            """
            
            if captureAllFuncArgsHistory && !params.isEmpty {
                template = """
                \(template)
                \(1.tab)\(acl)\(staticStr)var \(argsHistoryVarName) = \(argsHistoryVarType)()
                """
            }
            
            template = """
            \(template)
            \(1.tab)\(acl)\(staticStr)var \(handlerVarName): \(handlerVarType)
            \(1.tab)\(acl)\(staticStr)\(overrideStr)\(keyword)\(name)\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr)\(returnStr) {
            \(wrapped)
            \(1.tab)}
            """
        }
        
        return template
    }
}

