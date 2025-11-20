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
                              cast: String?,
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
            return argName.safeName
        }.joined(separator: ", ")
        let handlerReturnDefault = renderReturnDefaultStatement(name: name, type: returnDefaultType)
        
        let prefix = [
            throwing.hasError ? String.try + " " : nil,
            isAsync ? String.await + " " : nil,
        ].compactMap { $0 }.joined()
        
        let returnStr = returnDefaultType.isVoid ? "" : "return "

        var callAndReturnStmt = "\(returnStr)\(prefix)\(name)(\(handlerParamValsStr))\(cast ?? "")"

        /// For when a non-escaping closure argument is passed to the handler function as `Any`
        if case .closure(let closure) = type.kind {
            for (handlerArgType, (label, type)) in zip(closure.arguments.map(\.type), params) {
                guard handlerArgType == .Any && !type.isEscapable else {
                    continue
                }

                let prefix = [
                    closure.throwing.hasError ? String.try + " " : nil,
                    closure.isAsync ? String.await + " " : nil,
                ].compactMap { $0 }.joined()

                callAndReturnStmt = """
                \(returnStr)\(prefix)withoutActuallyEscaping(\(label.safeName)) { \(label.safeName) in
                \(callAndReturnStmt.addingIndent(1))
                }
                """
            }
        } else {
            assertionFailure("\(type) is not closure?")
        }

        return """
        \(2.tab)if let \(name) = \(name) {
        \(callAndReturnStmt.addingIndent(3))
        \(2.tab)}
        \(2.tab)\(handlerReturnDefault)
        """
    }
    
    
    private func renderReturnDefaultStatement(name: String, type: SwiftType) -> String {
        guard !type.isVoid else { return "" }
        
        if let result = type.defaultVal() {
            if result.isEmpty {
                return ""
            }
            return  "return \(result)"
        }

        return "\(String.fatalError)(\"\(name) returns can't have a default value thus its handler must be set\")"
    }
}
