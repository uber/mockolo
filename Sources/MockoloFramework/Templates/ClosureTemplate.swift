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

extension ClosureModel {
    func applyClosureTemplate(name: String,
                              type: Type,
                              genericTypeNames: [String],
                              paramVals: [String]?,
                              paramTypes: [Type]?,
                              suffix: String,
                              returnDefaultType: Type) -> String {
        
        var handlerParamValsStr = ""
        if let paramVals = paramVals, let paramTypes = paramTypes {
            let zipped = zip(paramVals, paramTypes).map { (arg) -> String in
                let (argName, argType) = arg
                if argType.isAutoclosure {
                    return argName.safeName + "()"
                }
                if argType.isInOut {
                    return "&" + argName.safeName
                }
                if argType.hasClosure && argType.isOptional,
                    let renderedClosure = renderOptionalGenericClosure(argType: argType, argName: argName) {
                    return renderedClosure
                }
                return argName.safeName
            }
            handlerParamValsStr = zipped.joined(separator: ", ")
        }
        let handlerReturnDefault = renderReturnDefaultStatement(name: name, type: returnDefaultType)
        
        let prefix = suffix.isThrowsOrRethrows ? String.SwiftKeywords.try.rawValue + " " : ""
        
        let returnStr = returnDefaultType.typeName.isEmpty ? "" : "return "
        let callExpr = "\(returnStr)\(prefix)\(name)(\(handlerParamValsStr))\(type.cast ?? "")"
        
        let template = """
        \(2.tab)if let \(name) = \(name) {
        \(3.tab)\(callExpr)
        \(2.tab)}
        \(2.tab)\(handlerReturnDefault)
        """
        
        return template
    }
    
    
    private func renderReturnDefaultStatement(name: String, type: Type) -> String {
        guard !type.isUnknown else { return "" }
        
        let result = type.defaultVal() ?? String.fatalError
        
        if result.isEmpty {
            return ""
        }
        if result.contains(String.fatalError) {
            return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
        }
        return  "return \(result)"
    }

    private func renderOptionalGenericClosure(
        argType: Type,
        argName: String
    ) -> String? {
        let literalComponents = argType.typeName.literalComponents
        for genericTypeName in genericTypeNames {
            if literalComponents.contains(genericTypeName) {
                var processTypeParams = argType.processTypeParams(with: genericTypeNames)
                let closureCast = processTypeParams.withoutTrailingCharacters(["!", "?"])
                return argName.safeName +
                    " as? " +
                closureCast
            }
        }
        return nil
    }
}
