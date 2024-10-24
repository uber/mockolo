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

final class NominalModel: Model {
    enum NominalTypeDeclKind: String {
        case `class`
        case `actor`
    }

    var name: String
    var offset: Int64
    var type: SwiftType
    let attribute: String
    let accessLevel: String
    let identifier: String
    let declTypeOfMockAnnotatedBaseType: DeclType
    let inheritedTypes: [String]
    let entities: [(String, Model)]
    let initParamCandidates: [VariableModel]
    let declaredInits: [MethodModel]
    let metadata: AnnotationMetadata?
    let declKind: NominalTypeDeclKind

    var modelType: ModelType {
        return .nominal
    }
    
    init(identifier: String,
         acl: String,
         declTypeOfMockAnnotatedBaseType: DeclType,
         declKind: NominalTypeDeclKind,
         inheritedTypes: [String],
         attributes: [String],
         offset: Int64,
         metadata: AnnotationMetadata?,
         initParamCandidates: [VariableModel],
         declaredInits: [MethodModel],
         entities: [(String, Model)]) {
        self.identifier = identifier 
        self.name = metadata?.nameOverride ?? (identifier + "Mock")
        self.type = SwiftType(self.name)
        self.declTypeOfMockAnnotatedBaseType = declTypeOfMockAnnotatedBaseType
        self.declKind = declKind
        self.inheritedTypes = inheritedTypes
        self.entities = entities
        self.declaredInits = declaredInits
        self.initParamCandidates = initParamCandidates
        self.metadata = metadata
        self.offset = offset
        self.attribute = Set(attributes.filter {$0.contains(String.available)}).joined(separator: " ")
        self.accessLevel = acl
    }
    
    func render(
        with identifier: String,
        encloser: String,
        useTemplateFunc: Bool,
        useMockObservable: Bool,
        allowSetCallCount: Bool = false,
        mockFinal: Bool = false,
        enableFuncArgsHistory: Bool = false,
        disableCombineDefaultValues: Bool = false
    ) -> String? {
        return applyNominalTemplate(
            name: name,
            identifier: self.identifier,
            accessLevel: accessLevel,
            attribute: attribute,
            declTypeOfMockAnnotatedBaseType: declTypeOfMockAnnotatedBaseType,
            inheritedTypes: inheritedTypes,
            metadata: metadata,
            useTemplateFunc: useTemplateFunc,
            useMockObservable: useMockObservable,
            allowSetCallCount: allowSetCallCount,
            mockFinal: mockFinal,
            enableFuncArgsHistory: enableFuncArgsHistory,
            disableCombineDefaultValues: disableCombineDefaultValues,
            initParamCandidates: initParamCandidates,
            declaredInits: declaredInits,
            entities: entities
        )
    }
}
