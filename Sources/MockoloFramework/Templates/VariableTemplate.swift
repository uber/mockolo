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

func applyVariableTemplate(name: String,
                           type: Type,
                           typeKeys: [String: String]?,
                           staticKind: String,
                           shouldOverride: Bool,
                           accessControlLevelDescription: String) -> String {

    let underlyingName = "\(String.underlyingVarPrefix)\(name.capitlizeFirstLetter)"
    let underlyingSetCallCount = "\(name)\(String.setCallCountSuffix)"
    let underlyingVarDefaultVal = type.defaultVal(with: typeKeys) ?? ""
    
    var underlyingType = type.typeName
    if underlyingVarDefaultVal.isEmpty {
        underlyingType = type.underlyingType
    }
    let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
    let setCallCountStmt = staticStr.isEmpty ? "if \(String.doneInit) { \(underlyingSetCallCount) += 1 }" : "\(underlyingSetCallCount) += 1"

    let overrideStr = shouldOverride ? "\(String.override) " : ""
    var acl = accessControlLevelDescription
    if !acl.isEmpty {
        acl = acl + " "
    }

    let template = """
    
    \(acl)\(staticStr)var \(underlyingSetCallCount) = 0
    \(staticStr)var \(underlyingName): \(underlyingType) \(underlyingVarDefaultVal.isEmpty ? "" : "= \(underlyingVarDefaultVal)")
    \(acl)\(staticStr)\(overrideStr)var \(name): \(type.typeName) {
        get { return \(underlyingName) }
        set {
            \(underlyingName) = newValue
            \(setCallCountStmt)
        }
    }
"""
    return template
}

func applyRxVariableTemplate(name: String,
                             type: Type,
                             typeKeys: [String: String]?,
                             staticKind: String,
                             shouldOverride: Bool,
                             accessControlLevelDescription: String) -> String? {
    let typeName = type.typeName
    if let range = typeName.range(of: String.observableVarPrefix), let lastIdx = typeName.lastIndex(of: ">") {
        let typeParamStr = typeName[range.upperBound..<lastIdx]
        
        let underlyingSubjectName = "\(name)\(String.subjectSuffix)"
        let whichSubject = "\(underlyingSubjectName)Kind"
        let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"
        let publishSubjectName = underlyingSubjectName
        let publishSubjectType = "\(String.publishSubject)<\(typeParamStr)>"
        let behaviorSubjectName = "\(name)\(String.behaviorSubject)"
        let behaviorSubjectType = "\(String.behaviorSubject)<\(typeParamStr)>"
        let replaySubjectName = "\(name)\(String.replaySubject)"
        let replaySubjectType = "\(String.replaySubject)<\(typeParamStr)>"
        let underlyingObservableName = "\(name)\(String.rx)\(String.subjectSuffix)"
        let underlyingObservableType = typeName[typeName.startIndex..<typeName.index(after: lastIdx)]
        let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription + " "
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
        let setCallCountStmt = staticStr.isEmpty ? "if \(String.doneInit) { \(underlyingSetCallCount) += 1 }" : "\(underlyingSetCallCount) += 1"

        let overrideStr = shouldOverride ? "\(String.override) " : ""
        
        let template = """
        
        \(staticStr)private var \(whichSubject) = 0
        \(acl)\(staticStr)var \(underlyingSetCallCount) = 0
        \(acl)\(staticStr)var \(publishSubjectName) = \(publishSubjectType)() { didSet { \(setCallCountStmt) } }
        \(acl)\(staticStr)var \(replaySubjectName) = \(replaySubjectType).create(bufferSize: 1) { didSet { \(setCallCountStmt) } }
        \(acl)\(staticStr)var \(behaviorSubjectName): \(behaviorSubjectType)! { didSet { \(setCallCountStmt) } }
        \(acl)\(staticStr)var \(underlyingObservableName): \(underlyingObservableType)! { didSet { \(setCallCountStmt) } }
        \(acl)\(staticStr)\(overrideStr)var \(name): \(typeName) {
            get {
                if \(whichSubject) == 0 {
                    return \(publishSubjectName)
                } else if \(whichSubject) == 1 {
                    return \(behaviorSubjectName)
                } else if \(whichSubject) == 2 {
                    return \(replaySubjectName)
                } else {
                    return \(underlyingObservableName)
                }
            }
            set {
                if let val = newValue as? \(publishSubjectType) {
                    \(publishSubjectName) = val
                    \(whichSubject) = 0
                } else if let val = newValue as? \(behaviorSubjectType) {
                    \(behaviorSubjectName) = val
                    \(whichSubject) = 1
                } else if let val = newValue as? \(replaySubjectType) {
                    \(replaySubjectName) = val
                    \(whichSubject) = 2
                } else {
                    \(underlyingObservableName) = newValue
                    \(whichSubject) = 3
                }
            }
        }
    """
        return template
    }
    return nil
}
