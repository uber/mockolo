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

private func resolveDefaultVal(typeName: String) -> String {
    if typeName.hasSuffix("?") {
        return "nil"
    } else {
        // TODO: 2. handle a comma case, e.g. in Observable<Int, String>, (Array<Int, String>, String)
        let subTypes = typeName.trimmingCharacters(in: CharacterSet(charactersIn: "()")).components(separatedBy: ",")
        let subTypeDefaultVals = subTypes.compactMap { (subType: String) -> String? in
            return defaultVal(typeName: subType)
        }
        
        if subTypeDefaultVals.count > 1 {
            return "(\(subTypeDefaultVals.joined(separator: ", ")))"
        } else if let val = subTypeDefaultVals.first {
            return val
        }
    }
    return ""
}

func applyVariableTemplate(name: String,
                           typeName: String,
                           staticKind: String,
                           accessControlLevelDescription: String) -> String {
    let underlyingName = "underlying\(name.capitlizeFirstLetter())"
    let underlyingSetCallCount = "\(name)SetCallCount"
    let underlyingVarDefaultVal = resolveDefaultVal(typeName: typeName)
    
    var underlyingType = typeName
    if underlyingVarDefaultVal.isEmpty {
        if underlyingType.hasSuffix("?") {
            underlyingType.removeLast()
        }
        if !underlyingType.hasSuffix("!") {
            underlyingType.append("!")
        }
    }
    
    let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription + " "
    let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
    
    let template =
    """
        \(staticStr)var \(underlyingSetCallCount) = 0
        \(staticStr)var \(underlyingName): \(underlyingType) \(underlyingVarDefaultVal.isEmpty ? "" : "= \(underlyingVarDefaultVal)")
        \(acl)\(staticStr)var \(name): \(typeName) {
             get {
                  return \(underlyingName)
             }
             set {
                  \(underlyingName) = newValue
                  \(underlyingSetCallCount) += 1
             }
        }
    """
    return template
}

func applyRxVariableTemplate(name: String,
                             typeName: String,
                             staticKind: String,
                             accessControlLevelDescription: String) -> String? {
    if let range = typeName.range(of: "Observable<"), let lastIdx = typeName.lastIndex(of: ">") {
        let typeParamStr = typeName[range.upperBound..<lastIdx]
        
        let underlying = "\(name)Subject"
        let underlyingSetCallCount = "\(underlying)SetCallCount"
        let underlyingType = "PublishSubject<\(typeParamStr)>"
        let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription + " "
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "

        let template =
        """
            \(staticStr)var \(underlyingSetCallCount) = 0
            \(staticStr)var \(underlying) = \(underlyingType)() {
                 didSet {
                     \(underlyingSetCallCount) += 1
                 }
            }
            \(acl)\(staticStr)var \(name): \(typeName) {
                return \(underlying)
            }
        """
        return template
    }
    return nil
}
