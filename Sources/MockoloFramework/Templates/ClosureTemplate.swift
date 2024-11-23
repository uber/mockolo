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
    func applyClosureTemplate(type: SwiftType,
                              name: String,
                              params: [(String, SwiftType)],
                              returnDefaultType: SwiftType) -> String {
        let handlerParamValsStr = params.map { (argName, argType) -> String in
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
        }.joined(separator: ", ")

        let prefix = [
            throwing.hasError ? String.try + " " : nil,
            isAsync ? String.await + " " : nil,
        ].compactMap { $0 }.joined()
        
        let returnStr = returnDefaultType.isVoid ? "" : "return "

        var template = """
        \(2.tab)if let \(name) = \(name) {
        \(3.tab)\(returnStr)\(prefix)\(name)(\(handlerParamValsStr))\(type.cast ?? "")
        \(2.tab)}
        """

        if let handlerReturnDefault = renderReturnDefaultStatement(name: name, type: returnDefaultType) {
            template += "\n\(2.tab)\(handlerReturnDefault)"
        }

        return template
    }
    
    
    private func renderReturnDefaultStatement(name: String, type: SwiftType) -> String? {
        guard !type.isUnknown else { return nil }

        if let result = type.defaultVal() {
            if result.isEmpty {
                return nil
            }
            return "return \(result)"
        }

        return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
    }

    private func renderOptionalGenericClosure(
        argType: SwiftType,
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
