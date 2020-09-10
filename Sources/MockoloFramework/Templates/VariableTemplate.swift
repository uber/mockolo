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


extension VariableModel {

    func applyVariableTemplate(name: String,
                               type: Type,
                               encloser: String,
                               isStatic: Bool,
                               shouldOverride: Bool,
                               accessLevel: String) -> String {
        
        let underlyingSetCallCount = "\(name)\(String.setCallCountSuffix)"
        let underlyingVarDefaultVal = type.defaultVal()
        var underlyingType = type.typeName
        if underlyingVarDefaultVal == nil {
            underlyingType = type.underlyingType
        }
        
        let overrideStr = shouldOverride ? "\(String.override) " : ""
        var acl = accessLevel
        if !acl.isEmpty {
            acl = acl + " "
        }
        
        var assignVal = ""
        if let val = underlyingVarDefaultVal {
            assignVal = "= \(val)"
        }
        
        let privateSetSpace = "\(String.privateSet) "
        let setCallCountStmt = "\(underlyingSetCallCount) += 1"
        
        var template = ""
        if isStatic || underlyingVarDefaultVal == nil {
            let staticSpace = isStatic ? "\(String.static) " : ""
            template = """

            \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(staticSpace)private var \(underlyingName): \(underlyingType) \(assignVal) { didSet { \(setCallCountStmt) } }
            \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(type.typeName) {
            \(2.tab)get { return \(underlyingName) }
            \(2.tab)set { \(underlyingName) = newValue }
            \(1.tab)}
            """
        } else {
            template = """

            \(1.tab)\(acl)\(privateSetSpace)var \(underlyingSetCallCount) = 0
            \(1.tab)\(acl)\(overrideStr)var \(name): \(type.typeName) \(assignVal) { didSet { \(setCallCountStmt) } }
            """
        }
        
        return template
    }
    
    func applyRxVariableTemplate(name: String,
                                 type: Type,
                                 encloser: String,
                                 overrideTypes: [String: String]?,
                                 shouldOverride: Bool,
                                 useMockObservable: Bool,
                                 isStatic: Bool,
                                 accessLevel: String) -> String? {
        
        let staticSpace = isStatic ? "\(String.static) " : ""
        let privateSetSpace = "\(String.privateSet) "

        if let overrideTypes = overrideTypes, !overrideTypes.isEmpty {
            let (subjectType, _, subjectVal) = type.parseRxVar(overrides: overrideTypes, overrideKey: name, isInitParam: true)
            if let underlyingSubjectType = subjectType {
                
                let underlyingSubjectName = "\(name)\(String.subjectSuffix)"
                let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"
                
                var defaultValAssignStr = ""
                if let underlyingSubjectTypeDefaultVal = subjectVal {
                    defaultValAssignStr = " = \(underlyingSubjectTypeDefaultVal)"
                } else {
                    defaultValAssignStr = ": \(underlyingSubjectType)!"
                }
                
                let acl = accessLevel.isEmpty ? "" : accessLevel + " "
                let overrideStr = shouldOverride ? "\(String.override) " : ""
                
                
                let setCallCountStmt = "\(underlyingSetCallCount) += 1"
                let fallbackName =  "\(String.underlyingVarPrefix)\(name)"
                var fallbackType = type.typeName
                if type.isIUO || type.isOptional {
                    fallbackType.removeLast()
                }

                let template = """

                \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
                \(1.tab)\(staticSpace)var \(fallbackName): \(fallbackType)? { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(underlyingSubjectName)\(defaultValAssignStr) { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(type.typeName) {
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
            let underlyingSetCallCount = "\(underlyingSubjectName)\(String.setCallCountSuffix)"
            let publishSubjectName = underlyingSubjectName
            let publishSubjectType = "\(String.publishSubject)<\(typeParamStr)>"
            let behaviorSubjectName = "\(name)\(String.behaviorSubject)"
            let behaviorSubjectType = "\(String.behaviorSubject)<\(typeParamStr)>"
            let replaySubjectName = "\(name)\(String.replaySubject)"
            let replaySubjectType = "\(String.replaySubject)<\(typeParamStr)>"
            let placeholderVal = "\(String.observableLeftAngleBracket)\(typeParamStr)>.empty()"

            let acl = accessLevel.isEmpty ? "" : accessLevel + " "
            let overrideStr = shouldOverride ? "\(String.override) " : ""
            let thisStr = isStatic ? encloser : "self"

            if useMockObservable {
                var mockObservableInitArgs = ""
                if type.isIUO || type.isOptional {
                    mockObservableInitArgs = "(wrappedValue: \(placeholderVal), unwrapped: \(placeholderVal))"
                } else {
                    mockObservableInitArgs = "(unwrapped: \(placeholderVal))"
                }

                let template = """

                \(1.tab)\(acl)\(staticSpace)var \(underlyingSetCallCount): Int { return \(thisStr)._\(name).callCount }
                \(1.tab)\(acl)\(staticSpace)var \(publishSubjectName): \(publishSubjectType) { return \(thisStr)._\(name).publishSubject }
                \(1.tab)\(acl)\(staticSpace)var \(replaySubjectName): \(replaySubjectType) { return \(thisStr)._\(name).replaySubject }
                \(1.tab)\(acl)\(staticSpace)var \(behaviorSubjectName): \(behaviorSubjectType) { return \(thisStr)._\(name).behaviorSubject }
                \(1.tab)\(String.mockObservable)\(mockObservableInitArgs) \(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName)
                """
                return template
            } else {
                let whichSubject = "\(underlyingSubjectName)Kind"
                let fallbackName = "_\(name)"
                let fallbackType = typeName[typeName.startIndex..<typeName.index(after: lastIdx)]
                let setCallCountStmt = "\(underlyingSetCallCount) += 1"

                let template = """
                \(1.tab)\(staticSpace)private var \(whichSubject) = 0
                \(1.tab)\(acl)\(staticSpace)\(privateSetSpace)var \(underlyingSetCallCount) = 0
                \(1.tab)\(acl)\(staticSpace)var \(publishSubjectName) = \(publishSubjectType)() { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(replaySubjectName) = \(replaySubjectType).create(bufferSize: 1) { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(behaviorSubjectName): \(behaviorSubjectType)! { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)var \(fallbackName): \(fallbackType)! { didSet { \(setCallCountStmt) } }
                \(1.tab)\(acl)\(staticSpace)\(overrideStr)var \(name): \(typeName) {
                \(2.tab)get {
                \(3.tab)if \(whichSubject) == 0 {
                \(4.tab)return \(publishSubjectName)
                \(3.tab)} else if \(whichSubject) == 1 {
                \(4.tab)return \(behaviorSubjectName)
                \(3.tab)} else if \(whichSubject) == 2 {
                \(4.tab)return \(replaySubjectName)
                \(3.tab)} else {
                \(4.tab)return \(fallbackName)
                \(3.tab)}
                \(2.tab)}
                \(2.tab)set {
                \(3.tab)if let val = newValue as? \(publishSubjectType) {
                \(4.tab)\(publishSubjectName) = val
                \(4.tab)\(whichSubject) = 0
                \(3.tab)} else if let val = newValue as? \(behaviorSubjectType) {
                \(4.tab)\(behaviorSubjectName) = val
                \(4.tab)\(whichSubject) = 1
                \(3.tab)} else if let val = newValue as? \(replaySubjectType) {
                \(4.tab)\(replaySubjectName) = val
                \(4.tab)\(whichSubject) = 2
                \(3.tab)} else {
                \(4.tab)\(fallbackName) = newValue
                \(4.tab)\(whichSubject) = 3
                \(3.tab)}
                \(2.tab)}
                \(1.tab)}
                """
                return template
            }
        }
        return nil
    }
}


