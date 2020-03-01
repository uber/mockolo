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
    
    let overrideStr = shouldOverride ? "\(String.override) " : ""
    var acl = accessControlLevelDescription
    if !acl.isEmpty {
        acl = acl + " "
    }
    
    let assignVal = underlyingVarDefaultVal.isEmpty ? "" : "= \(underlyingVarDefaultVal)"
    var setCallCountStmt = "\(underlyingSetCallCount) += 1"
    
    var template = ""
    if !staticKind.isEmpty ||  underlyingVarDefaultVal.isEmpty {
        if staticKind.isEmpty {
            setCallCountStmt = "if \(String.doneInit) { \(underlyingSetCallCount) += 1 }"
        }
        
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
        
        template = """
        \(1.tab)\(acl)\(staticStr)var \(underlyingSetCallCount) = 0
        \(1.tab)\(staticStr)var \(underlyingName): \(underlyingType) \(assignVal)
        \(1.tab)\(acl)\(staticStr)\(overrideStr)var \(name): \(type.typeName) {
        \(2.tab)get { return \(underlyingName) }
        \(2.tab)set {
        \(3.tab)\(underlyingName) = newValue
        \(3.tab)\(setCallCountStmt)
        \(2.tab)}
        \(1.tab)}
        """
    } else {
        template = """
        \(1.tab)\(acl)var \(underlyingSetCallCount) = 0
        \(1.tab)\(acl)\(overrideStr)var \(name): \(type.typeName) \(assignVal) { didSet { \(setCallCountStmt) } }
        """
    }
    
    return template
}

func applyRxVariableTemplate(name: String,
                             type: Type,
                             overrideTypes: [String: String]?,
                             typeKeys: [String: String]?,
                             staticKind: String,
                             shouldOverride: Bool,
                             accessControlLevelDescription: String) -> String? {
    if let overrideTypes = overrideTypes, !overrideTypes.isEmpty {
        let (subjectType, subjectVal) = type.parseRxVar(overrides: overrideTypes, overrideKey: name, isInitParam: true)
        if let underlyingSubjectType = subjectType {
            
            let underlyingSubjectName = "\(name)\(String.subjectSuffix)"
            let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"
            
            var defaultValAssignStr = ""
            if let underlyingSubjectTypeDefaultVal = subjectVal {
                defaultValAssignStr = " = \(underlyingSubjectTypeDefaultVal)"
            } else {
                defaultValAssignStr = ": \(underlyingSubjectType)!"
            }
            
            let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription + " "
            let overrideStr = shouldOverride ? "\(String.override) " : ""
            let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
            let incrementCallCount = "\(underlyingSetCallCount) += 1"
            let setCallCountStmt = staticKind.isEmpty ? "if \(String.doneInit) { \(incrementCallCount) }" : incrementCallCount
            let fallbackName =  "\(String.underlyingVarPrefix)\(name.capitlizeFirstLetter)"
            var fallbackType = type.typeName
            if type.isIUO || type.isOptional {
                fallbackType.removeLast()
            }
            
            let template = """
            \(1.tab)\(acl)\(staticStr)var \(underlyingSetCallCount) = 0
            \(1.tab)\(staticStr)var \(fallbackName): \(fallbackType)? { didSet { \(setCallCountStmt) } }
            \(1.tab)\(acl)\(staticStr)var \(underlyingSubjectName)\(defaultValAssignStr) { didSet { \(setCallCountStmt) } }
            \(1.tab)\(acl)\(staticStr)\(overrideStr)var \(name): \(type.typeName) {
            \(2.tab)get { return \(fallbackName) ?? \(underlyingSubjectName) }
            \(2.tab)set { if let val = newValue as? \(underlyingSubjectType) { \(underlyingSubjectName) = val } else { \(fallbackName) = newValue } }
            \(1.tab)}
            """
            
            return template
        }
    }
    
    let typeName = type.typeName
    if let range = typeName.range(of: String.observableLeftAngleBracket), let lastIdx = typeName.lastIndex(of: ">") {
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
        let underlyingObservableName = "\(String.underlyingVarPrefix)\(name.capitlizeFirstLetter)"
        let underlyingObservableType = typeName[typeName.startIndex..<typeName.index(after: lastIdx)]
        let acl = accessControlLevelDescription.isEmpty ? "" : accessControlLevelDescription + " "
        let staticStr = staticKind.isEmpty ? "" : "\(staticKind) "
        let setCallCountStmt = staticStr.isEmpty ? "if \(String.doneInit) { \(underlyingSetCallCount) += 1 }" : "\(underlyingSetCallCount) += 1"
        let overrideStr = shouldOverride ? "\(String.override) " : ""
        
        let template = """
        \(1.tab)\(staticStr)private var \(whichSubject) = 0
        \(1.tab)\(acl)\(staticStr)var \(underlyingSetCallCount) = 0
        \(1.tab)\(acl)\(staticStr)var \(publishSubjectName) = \(publishSubjectType)() { didSet { \(setCallCountStmt) } }
        \(1.tab)\(acl)\(staticStr)var \(replaySubjectName) = \(replaySubjectType).create(bufferSize: 1) { didSet { \(setCallCountStmt) } }
        \(1.tab)\(acl)\(staticStr)var \(behaviorSubjectName): \(behaviorSubjectType)! { didSet { \(setCallCountStmt) } }
        \(1.tab)\(acl)\(staticStr)var \(underlyingObservableName): \(underlyingObservableType)! { didSet { \(setCallCountStmt) } }
        \(1.tab)\(acl)\(staticStr)\(overrideStr)var \(name): \(typeName) {
        \(2.tab)get {
        \(3.tab)if \(whichSubject) == 0 { return \(publishSubjectName) }
        \(3.tab)else if \(whichSubject) == 1 { return \(behaviorSubjectName) }
        \(3.tab)else if \(whichSubject) == 2 { return \(replaySubjectName) }
        \(3.tab)else { return \(underlyingObservableName) }
        \(2.tab)}
        \(2.tab)set {
        \(3.tab)if let val = newValue as? \(publishSubjectType) { \(whichSubject) = 0; \(publishSubjectName) = val }
        \(3.tab)else if let val = newValue as? \(behaviorSubjectType) { \(whichSubject) = 1; \(behaviorSubjectName) = val }
        \(3.tab)else if let val = newValue as? \(replaySubjectType) { \(whichSubject) = 2; \(replaySubjectName) = val }
        \(3.tab)else { \(whichSubject) = 3; \(underlyingObservableName) = newValue }
        \(2.tab)}
        \(1.tab)}
        """
        return template
    }
    return nil
}
