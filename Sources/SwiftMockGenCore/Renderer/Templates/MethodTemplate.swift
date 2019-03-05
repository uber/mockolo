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
                         paramDecls: [String],
                         returnType: String,
                         staticKind: String,
                         accessControlLevelDescription: String,
                         handlerVarName: String,
                         handlerVarType: String,
                         handlerReturn: String) -> String {
    // identifier.contains(suffixStr) ? methodShortName : methodShortName + suffixStr
    let callCount = "\(identifier)\(CallCountSuffix)"
    let paramDeclsStr = paramDecls.joined(separator: ", ")
    let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription+" "
    let returnStr = returnType.isEmpty ? "" : "-> \(returnType)"
    let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "

    let template =
    """
        \(staticStr)var \(callCount) = 0
        \(staticStr)var \(handlerVarName): \(handlerVarType)
        \(acl)\(staticStr)func \(name)(\(paramDeclsStr)) \(returnStr) {
            \(callCount) += 1
            \(handlerReturn)
        }
    """
    return template
}

private func renderMethodParamNames(_ elements: [Structure], capitalized: Bool) -> [String] {
    return elements.map { (element: Structure) -> String in
        return capitalized ? element.name.capitlizeFirstLetter() : element.name
    }
}

